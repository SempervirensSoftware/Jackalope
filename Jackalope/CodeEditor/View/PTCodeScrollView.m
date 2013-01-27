//
//  PTCodeScrollView.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTCodeScrollView.h"
#import <CoreText/CoreText.h>
#import "PTLineOfCode.h"
#import "PTCursorLayer.h"
#import "PTTextPosition.h"
#import "PTTextRange.h"

#import "TextSelectionPopupViewController.h"
#import "WEPopoverController.h"

// We use a tap gesture recognizer to allow the user to tap to invoke text edit mode
@interface PTCodeScrollView()

@property (nonatomic, retain) PTCursorLayer* cursorLayer;
@property (nonatomic, retain) PTSelectionLayer* selectionLayer;

- (void) tapsRecognized:(UITapGestureRecognizer *)recognizer;
- (void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer  withPriorityLength:(float)priorityLength;

-(void) registerForKeyboardNotifications;

-(void) setSelectionAtPoint:(CGPoint)point shouldSelectWord:(BOOL)selectWord;
-(PTCodeLayer*)findCodeLayerForPoint:(CGPoint)point;

-(void) showTextSelectionPopup;
-(void) dismissTextSelectionPopupAnimated:(BOOL)shouldAnimate;

-(void) textDidChange;
-(void) textWillChange;
-(void) selectionDidChange;
-(void) selectionWillChange;

-(void) clearCodeEditor;

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: - Async Operations
/////////////////////////////////////////////////////////////////////////////
@interface AsyncShiftLayerOperation : NSOperation
    {
        PTCodeScrollView*   _scrollView;
        PTCodeLayer*        _updatedLayer;
        float               _deltaY;
        NSInteger           _deltaLineNums;
    }

    -(id)initWithScrollView:        (PTCodeScrollView *)scrollView updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer;
    +(id)operationWithScrollView:   (PTCodeScrollView *)scrollView updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer;
@end


/////////////////////////////////////////////////////////////////////////////
// MARK: - PTCodeScrollView
/////////////////////////////////////////////////////////////////////////////

@implementation PTCodeScrollView

@synthesize selection = _selection;
@synthesize code = _code;
@synthesize isDiff = _isDiff;

@synthesize markedTextRange, markedTextStyle, selectedTextRange, beginningOfDocument, endOfDocument, inputDelegate, tokenizer;

/////////////////////////////////////////////////////////////////////////////
// MARK: - Initialization
/////////////////////////////////////////////////////////////////////////////

-(void) commonInit
{    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapsRecognized:)];
    doubleTapRecognizer.numberOfTapsRequired=2;
    [self addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapsRecognized:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delaysTouchesEnded = YES;
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:singleTapRecognizer];
    
    [self registerForKeyboardNotifications];
    
    _keyboardRect = CGRectNull;
    _newlineCharSet = [NSCharacterSet newlineCharacterSet];
    _layerArray = [[NSMutableArray alloc] initWithCapacity:1];

    // setup the selection sub layers
    
    NSDictionary *layerActionOverride = @{
        @"onOrderIn": [NSNull null],
        @"onOrderOut": [NSNull null],
        @"sublayers": [NSNull null],
        @"contents": [NSNull null],
        @"bounds": [NSNull null],
        @"position": [NSNull null]
    };        
    self.cursorLayer = [[PTCursorLayer alloc] init];
    self.cursorLayer.contentsScale = [UIScreen mainScreen].scale;
    self.cursorLayer.actions = layerActionOverride;
    self.selectionLayer = [[PTSelectionLayer alloc] init];
    self.selectionLayer.contentsScale = [UIScreen mainScreen].scale;
    self.selectionLayer.actions = layerActionOverride;

    _maxFrameSize               = 50;
    _numberOfScreensToBuffer    = 3;
    _numberOfExtraScrollLines   = 2;
    
    _whiteSpaceRegex = [NSRegularExpression 
                        regularExpressionWithPattern:@"^[\t ]*"
                        options:0
                        error:NULL];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _codeViewDelegates = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.contentMode = UIViewContentModeLeft;
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 1.0;
    self.delegate = self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(Code *) code
{
    NSMutableString* codeText = [[NSMutableString alloc] init];
    
    for (PTCodeLayer* layer in _layerArray)
    {
        [codeText appendString:[layer fullText]];
    }
    
    _code.plainText = codeText;
    
    return _code;
}


-(void) setCode:(Code *)code
{
    [self clearCodeEditor];
    
    if (!code || !(code.plainText))
    {
        [_codeEditor setNeedsDisplay];
        return;
    }
    
    _code = code;    
    _decorator = [[PTDecoratorCollection getInstance] decoratorForFileName:code.fileName];        
    _layerArray = [[NSMutableArray alloc] init];
    [self hideKeyboard];
    
    NSAttributedString* decoratedCode = [_decorator decorateString:code.plainText];    
    NSInteger   fullLength = [code.plainText length];
    NSInteger   loadSize = 5000; // want to be conservative. should be tested to find optimal value
    
    NSInteger   currentIndex = 0;
    NSInteger   currentLineNum = 1;
    CGRect      currentFrame = CGRectMake(0, 2, self.frame.size.width, 12);
    
    _codeEditor = [[UIView alloc] initWithFrame:currentFrame];
        
    while (currentIndex < fullLength)
    {
        if ((fullLength - currentIndex) < loadSize){
            loadSize = (fullLength - currentIndex);
        }
        
        PTCodeLayer* currentLayer = [[PTCodeLayer alloc] init];
        currentLayer.frame = currentFrame;
        currentLayer.contentsScale = [UIScreen mainScreen].scale;
        currentLayer.suggestedLineLimit = 10;
        currentLayer.startingLineNum = currentLineNum;
        if (self.isDiff)
        {
            currentLayer.displayMode = EDITOR_DISPLAY_DIFF;
        }
        
        NSInteger numCharsLoaded = [currentLayer loadAttributedString:[decoratedCode attributedSubstringFromRange:NSMakeRange(currentIndex, loadSize)]];
        [currentLayer setNeedsDisplay];
        
        [_layerArray addObject:currentLayer];
        [_codeEditor setFrame:CGRectMake(_codeEditor.frame.origin.x, _codeEditor.frame.origin.y, _codeEditor.frame.size.width, (_codeEditor.frame.size.height + currentLayer.frame.size.height))];
        [_codeEditor.layer addSublayer:currentLayer];        
        
        currentIndex = (currentIndex + numCharsLoaded);
        currentLineNum = (currentLineNum + [currentLayer.locArray count]);
        currentFrame.origin.y = (currentFrame.origin.y + currentLayer.frame.size.height);
    }
    
    [self setContentSize:_codeEditor.frame.size];

    // clear out the old views, and add the latest and greatest
    for (UIView* subview in self.subviews) { [subview removeFromSuperview]; }
    [self addSubview:_codeEditor];   
}

-(void) clearCodeEditor
{
    for (CALayer* layer in _layerArray)
    {
        [layer removeFromSuperlayer];
    }
    
    [_layerArray removeAllObjects];
}

-(BOOL) highlightText:(NSString*)searchText {
    if (searchText) {
        PTTextRange *range = nil;
        PTTextPosition *startPosition = (PTTextPosition*) self.selection.end;
        PTCodeLayer *startLayer = startPosition.layer;
        BOOL startSearching = startLayer ? false : true;
        
        for (PTCodeLayer* layer in _layerArray)
        {
            if (!startSearching && (layer != startLayer)){
                continue;
            } else if (!startSearching) {
                startSearching = YES;
            }
            
            range = [layer rangeForSearchString:searchText startingAtPosition:startPosition];
            if (range){
                [self setSelection:range];
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark Custom user interaction

-(void) setSelectionAtPoint:(CGPoint)point shouldSelectWord:(BOOL)selectWord {
    PTCodeLayer *currentLayer = [self findCodeLayerForPoint:point];
    if (currentLayer) {
        _currentLayer = currentLayer;
        PTTextRange* range = nil;
        PTTextPosition* tapPosition = [currentLayer closestPositionToPoint:point];
        
        if (selectWord){
            CFStringRef lineString = CFAttributedStringGetString(tapPosition.loc.attributedText);
            if (lineString != NULL){
                
                NSMutableCharacterSet *wordCharacters = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
                [wordCharacters addCharactersInString:@"_"];
      
                // look backwards
                NSUInteger startIndex = tapPosition.index;
                Boolean foundWordStart = false;
                while (!foundWordStart && startIndex > 0){
                    NSUInteger nextIndex = startIndex - 1;
                    UniChar prevChar = CFStringGetCharacterAtIndex(lineString, nextIndex);
                    Boolean prevCharIsInWord = [wordCharacters characterIsMember:prevChar];
                    Boolean prevCharIsNewLine = [_newlineCharSet characterIsMember:prevChar];
                    
                    if (prevCharIsInWord && !prevCharIsNewLine){
                        startIndex = nextIndex;
                    } else {
                        foundWordStart = true;
                    }
                }
                PTTextPosition *startPosition = [PTTextPosition positionInLayer:currentLayer InLine:tapPosition.loc WithIndex:startIndex];
                
                // look forwards
                NSUInteger endIndex = tapPosition.index;
                NSUInteger length = CFStringGetLength(lineString);
                Boolean foundWordEnd = false;
                while (!foundWordEnd && endIndex < length){
                    UniChar endChar = CFStringGetCharacterAtIndex(lineString, endIndex);
                    Boolean endCharIsInWord = [wordCharacters characterIsMember:endChar];

                    if (endCharIsInWord){
                        endIndex++;
                    } else {
                        foundWordEnd = true;
                    }
                }
                PTTextPosition *endPosition = [PTTextPosition positionInLayer:currentLayer InLine:tapPosition.loc WithIndex:endIndex];
                
                NSLog(@"Selected word: [%i - %i]",startIndex, endIndex);
                range = [PTTextRange rangeWithStartPosition:startPosition andEndPosition:endPosition];
            }
            
        } else {
            range = [PTTextRange rangeWithStartPosition:tapPosition andEndPosition:tapPosition];
        }

        self.selection = range;
    }
}

-(PTCodeLayer*)findCodeLayerForPoint:(CGPoint)point {
    PTCodeLayer *result = nil;
    
    for (PTCodeLayer* layer in _layerArray)
    {
        if ((point.y >= layer.frame.origin.y) && (point.y <= (layer.frame.origin.y + layer.frame.size.height)))
        {
            result = layer;
            break;
        }
    }
    
    return result;
}

-(void) setSelection:(PTTextRange *)selection {    
    _selection = selection;
    
    [self clearSelectionLayers];
    
    PTTextPosition* start = (PTTextPosition*)selection.start;
    PTTextPosition* end = (PTTextPosition*)selection.end;
    
    if (!start){
        return;
    }
    else if (selection.empty){
        self.cursorLayer.frame = [_currentLayer createRectForPosition:start];
        [self.cursorLayer startBlinking];
        [_codeEditor.layer insertSublayer:self.cursorLayer above:_currentLayer];
    } else {
        CGRect startRect = [_currentLayer createRectForPosition:start];
        CGRect endRect = [_currentLayer createRectForPosition:end];
        
        CGFloat height = (endRect.origin.y + endRect.size.height) - startRect.origin.y;
        CGRect selectionRect = CGRectMake(0, startRect.origin.y, start.loc.displayRect.size.width, height);
        self.selectionLayer.frame = selectionRect;
        self.selectionLayer.startRect = startRect;
        self.selectionLayer.endRect = endRect;
        [self.selectionLayer setNeedsDisplay];
        [_codeEditor.layer insertSublayer:self.selectionLayer below:_currentLayer];
        [self showTextSelectionPopup];
    }
}

-(void) activateSelectionLayers {
    if ([self.cursorLayer superlayer]){
        [self.cursorLayer startBlinking];
    }  
}


-(void) deactivateSelectionLayers {
    if ([self.cursorLayer superlayer]){
        [self.cursorLayer stopBlinking];
    }
}

-(void) clearSelectionLayers{
    if ([self.cursorLayer superlayer]){
        [self.cursorLayer stopBlinking];
        [self.cursorLayer removeFromSuperlayer];
    }
    
    if ([self.selectionLayer superlayer]){
        [self.selectionLayer removeFromSuperlayer];
    }
}

#pragma mark -
#pragma mark Menu commands and validation

/*
 The view implements this method to conditionally enable or disable commands of the editing menu.
 The canPerformAction:withSender method is declared by UIResponder.
 */

- (void)tapsRecognized:(UITapGestureRecognizer *)recognizer{
    if (![self isFirstResponder]) {
        [self showKeyboard];
    }
    
    // Find and update selection
    [self selectionWillChange];
    
    CGPoint tapPoint = [recognizer locationInView:_codeEditor];
    if (recognizer.numberOfTapsRequired == 1){
        [self setSelectionAtPoint:tapPoint shouldSelectWord:NO];
    } else {
        [self setSelectionAtPoint:tapPoint shouldSelectWord:YES];
    }
    
    [self selectionDidChange];
}


-(void) showTextSelectionPopup{
    UIMenuController *theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:self.selectionLayer.endRect inView:self];
    [theMenu setMenuVisible:YES animated:YES];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL retValue = NO;
	
	if (action == @selector(paste:) || action == @selector(cut:) || action == @selector(copy:)) {
		// The square must have no tile and there must be a ColorTile object in the pasteboard.
		retValue = YES;
	}

    return retValue;
}

/*
 These methods are declared by the UIResponderStandardEditActions informal protocol.
 */
- (void)copy:(id)sender {
    
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.string = [self textInRange:self.selection];
}


- (void)cut:(id)sender {
    [self copy:sender];
    [self deleteBackward];
}


- (void)paste:(id)sender {    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    NSString *newText = pasteBoard.string;
    [self insertText:newText];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    //return _codeEditor;
    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    NSLog(@"scale:%f",scale);
}

-(void)drawRect:(CGRect)rect
{
    float _leftColumnWidth = 28;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGContextSetRGBFillColor(ctx, 255/255.f, 255/255.f, 255/255.f, 1);
    CGContextFillRect(ctx, self.frame);        
    
    
    CGRect leftColumnRect = {self.frame.origin.x, self.frame.origin.y, _leftColumnWidth, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 220/255.f, 220/255.f, 220/255.f, 1);
    CGContextFillRect(ctx, leftColumnRect);        
    
    CGRect leftColumnBorder = {(self.frame.origin.x + _leftColumnWidth), self.frame.origin.y, 1, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 140/255.f, 140/255.f, 140/255.f, 1);
    CGContextFillRect(ctx, leftColumnBorder);        

    [super drawRect:rect];
}


#pragma mark UIKeyInput methods

// UIKeyInput required method - A Boolean value that indicates whether the text-entry 
// objects have any text.
- (BOOL)hasText
{
    return (_code != nil);
}

// UIKeyInput required method - Insert a character into the displayed text.
// Called by the text system when the user has entered simple text
- (void)insertText:(NSString *)text
{
    [self insertText:text andMoveCursor:YES];
}

- (void)insertText:(NSString *)text andMoveCursor:(BOOL)moveCursor
{
    if (!text || ([text length] == 0) || !self.selection) {
        return;
    }

    if (!self.selection.empty){
        // we want to clear out the selected text before inserting the new stuff
        // why? because that how text editors work!
        [self deleteBackward];
    }
    
    [self textWillChange];
    
    NSInteger initLocCount = [_currentLayer.locArray count];
    CGFloat initLayerHeight = _currentLayer.frame.size.height;
    __block PTTextPosition* currentPos = [((PTTextPosition*)self.selection.start) copy];
    
    // need to split up the inserted text in a block to accommodate any newline characters
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByLines usingBlock:
        ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

            NSMutableString*    lineString  = [(__bridge NSString*)CFAttributedStringGetString(currentPos.loc.attributedText) mutableCopy];                        
            PTTextPosition*     nextPos     = nil;
            PTLineOfCode*         newLoc      = nil;
            
            if (substringRange.length > 0)
            {                
                [lineString insertString:substring atIndex:currentPos.index];
                currentPos.index += substringRange.length;
            }
       
            // if this substring isn't at the end up the insertText there must be a newline up next
            if ((substringRange.location + substringRange.length) < (enclosingRange.location + enclosingRange.length))
            {                
                NSMutableString* newlineText = [[lineString substringFromIndex:currentPos.index] mutableCopy];
                NSRange remainingRange = NSMakeRange(currentPos.index, newlineText.length);
                __block NSRange indentationRange = NSMakeRange(0, 0);
                
                [_whiteSpaceRegex enumerateMatchesInString:lineString options:0 range:NSMakeRange(0, [lineString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    indentationRange = [result range];
                }];
                
                if (indentationRange.length > 0)
                {
                    NSString* indentation = [lineString substringWithRange:indentationRange];
                    [newlineText insertString:indentation atIndex:0];
                }
                
                [lineString replaceCharactersInRange:remainingRange withString:@"\n"]; //hardcoding the neline character right now...                
                NSAttributedString* newLine = [_decorator decorateString:newlineText];

                newLoc = [[PTLineOfCode alloc] initWithAttributedString:(__bridge CFAttributedStringRef)newLine];            
                nextPos = [PTTextPosition positionInLayer:_currentLayer InLine:newLoc WithIndex:indentationRange.length];
            }

            currentPos.loc.attributedText = (__bridge CFAttributedStringRef)[_decorator decorateString:lineString];
            [_currentLayer updateLine:currentPos.loc];
            
            if (newLoc)
            {
                [_currentLayer insertLine:newLoc afterLine:currentPos.loc];
                currentPos = nextPos;
            }
        }
     ];
    
    if (moveCursor){
        self.selection = [PTTextRange rangeWithStartPosition:currentPos andEndPosition:currentPos];
        [self scrollToCursor];
    }
    
    NSInteger deltaLocCount = ([_currentLayer.locArray count] - initLocCount);
    CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - initLayerHeight);
    [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:deltaLocCount startingAfterLayer:_currentLayer];
    
    [self textDidChange];
}

// UIKeyInput required method - Delete a character from the displayed text.
// Called by the text system when the user is invoking a delete (e.g. pressing
// the delete software keyboard key)
- (void)deleteBackward 
{
    [self textWillChange];    
    
    if (self.selection.empty){
        PTTextPosition* currentPos = (PTTextPosition*)self.selection.start;
        
        NSMutableString* lineString = [(__bridge NSString*)CFAttributedStringGetString(currentPos.loc.attributedText) mutableCopy];    

        // Standard case. Just delete the character to the left of the cursor
        if (currentPos.index != 0)
        {            
            [lineString deleteCharactersInRange:NSMakeRange((currentPos.index-1), 1)];
            
            CGFloat oldHeight = _currentLayer.frame.size.height;
            currentPos.loc.attributedText = (__bridge CFAttributedStringRef)[_decorator decorateString:lineString];
            [_currentLayer updateLine:currentPos.loc];
            
            CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);        
            [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:0 startingAfterLayer:_currentLayer];
            
            currentPos.index -= 1;
            self.selection = [PTTextRange rangeWithStartPosition:currentPos andEndPosition:currentPos];
        }
        
        // Special Case. Need to add this line's text to the previous line (if there is one)
        else {
            NSArray* currentLocArray = _currentLayer.locArray;
            PTLineOfCode* oldLoc = currentPos.loc;
            PTLineOfCode* newLoc = nil;
            NSInteger locIndex = [currentLocArray indexOfObject:oldLoc];        
            
            // if this isn't the first line in the layer. we want to update it's predecessor
            if (locIndex > 0) {
                CGFloat oldHeight = _currentLayer.frame.size.height;
                [_currentLayer removeLine:oldLoc];

                CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);            
                [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:(-1) startingAfterLayer:_currentLayer];

                newLoc = [currentLocArray objectAtIndex:(locIndex-1)];
            }
            // if this is the first line in the layer, we need to pull up the last loc in the previous frame
            else {
                NSInteger currentLayerIndex = [_layerArray indexOfObject:_currentLayer];
                
                // if there are no previous characters, loc's or layers we don't do anything for the delete key
                if (currentLayerIndex > 0) {
                    CGFloat oldHeight = _currentLayer.frame.size.height;                
                    [_currentLayer removeLine:oldLoc];

                    CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);                
                    [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:(-1) startingAfterLayer:_currentLayer];
                    
                    _currentLayer = [_layerArray objectAtIndex:(currentLayerIndex-1)];
                    newLoc = _currentLayer.locArray.lastObject;
                }
            }

            if (newLoc) {
                // strip the newline off this guy. there should already be one on the line above
                [lineString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [lineString length])];
                PTTextPosition* newPos = [PTTextPosition positionInLayer:_currentLayer InLine:newLoc WithIndex:(CFAttributedStringGetLength(newLoc.attributedText)-1)];
                self.selection = [PTTextRange rangeWithStartPosition:newPos andEndPosition:newPos];
                [self insertText:lineString andMoveCursor:NO];
            }
        }
    } else { // this means we need to delete all the selected text
        PTTextPosition *start = (PTTextPosition*)self.selection.start;
        PTTextPosition *end = (PTTextPosition*)self.selection.end;
        
        if (start.loc == end.loc) {
            int selectionLength = end.index - start.index;
            NSMutableString* lineString = [(__bridge NSString*)CFAttributedStringGetString(start.loc.attributedText) mutableCopy];
            [lineString deleteCharactersInRange:NSMakeRange((start.index), selectionLength)];
            
            CGFloat oldHeight = _currentLayer.frame.size.height;
            start.loc.attributedText = (__bridge CFAttributedStringRef)[_decorator decorateString:lineString];
            [_currentLayer updateLine:start.loc];
            
            CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);
            [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:0 startingAfterLayer:_currentLayer];
            
            self.selection = [PTTextRange rangeWithStartPosition:start andEndPosition:start];
        } else {
            // The selection covers multiple lines
            // TODO support multi loc selection
        }
        
    }
    
    [self scrollToCursor];
    [self textDidChange];
}

-(void) addCodeViewDelegate:(id<PTCodeViewDelegate>)delegate{
    [_codeViewDelegates addObject:delegate];
}
-(void) removeCodeViewDelegate:(id<PTCodeViewDelegate>)delegate{
    [_codeViewDelegates removeObject:delegate];
}
-(void) textDidChange{
    [self.inputDelegate textDidChange:self];
    
    for (id<UITextInputDelegate> delegate in _codeViewDelegates){
        [delegate textDidChange:self];
    }
}
-(void) textWillChange{
    [self.inputDelegate textWillChange:self];
    
    for (id<UITextInputDelegate> delegate in _codeViewDelegates){
        [delegate textWillChange:self];
    }    
}
-(void) selectionDidChange{
    [self.inputDelegate selectionDidChange:self];
    
    for (id<UITextInputDelegate> delegate in _codeViewDelegates){
        [delegate selectionDidChange:self];
    }        
}
-(void) selectionWillChange{
    [self.inputDelegate selectionWillChange:self];
    
    for (id<UITextInputDelegate> delegate in _codeViewDelegates){
        [delegate selectionWillChange:self];
    }    
}

#pragma mark UITextInputTraits methods
-(UITextAutocapitalizationType) autocapitalizationType  {return UITextAutocapitalizationTypeNone;}
-(UITextAutocorrectionType)     autocorrectionType      {return UITextAutocorrectionTypeNo;}
-(UITextSpellCheckingType)      spellCheckingType       {return UITextSpellCheckingTypeNo;}

#pragma mark UITextInput methods
- (NSString *)textInRange:(UITextRange *)range{
    NSString *result = nil;
    
    if ([range isKindOfClass:[PTTextRange class]]){
        PTTextPosition *start = (PTTextPosition*)range.start;
        PTTextPosition *end = (PTTextPosition*)range.end;
        
        if (start.loc == end.loc) {
            int selectionLength = end.index - start.index;
            CFStringRef lineString = CFAttributedStringGetString(start.loc.attributedText);
            result = (__bridge_transfer NSString*)CFStringCreateWithSubstring(CFAllocatorGetDefault(), lineString, CFRangeMake(start.index, selectionLength));
        } else {
            // TODO: support selecting multple lines
        }
    }
    
    return result;
}
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text{
    NSLog(@"Unimplemented - replaceRange:withText:");
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange{  // selectedRange is a range within the markedText
    NSLog(@"Unimplemented - setMarkedText:selectedRange:");
}
- (void)unmarkText{
    NSLog(@"Unimplemented - unmarkText");
}

/* Methods for creating ranges and positions. */
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition{
    NSLog(@"Unimplemented - textRangeFromPosition:toPosition");
    return nil;    
}
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset{
    NSLog(@"Unimplemented - positionFromPosition:offset");
    return nil;    
}
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset{
    NSLog(@"Unimplemented - positionFromPosition:inDirection:offset");
    return nil;    
}

/* Simple evaluation of positions */
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other{
    NSLog(@"Unimplemented - comparePosition:toPosition");
    return NSOrderedSame;
}
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition{
    NSLog(@"Unimplemented - offsetFromPosition:toPosition");
    return 1;
}

/* Layout questions. */
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction{
    NSLog(@"Unimplemented - positionWithinRange:farthestInDirection");
    return nil;    
}
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction{
    NSLog(@"Unimplemented - characterRangeByExtendingPosition:inDirection");
    return nil;    
}

/* Writing direction */
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction{
    NSLog(@"Unimplemented - baseWritingDirectionForPosition:inDirection");
    return UITextWritingDirectionLeftToRight;    
}
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range{
    NSLog(@"Unimplemented - setBaseWritingDirection:forRange");
}

/* Geometry used to provide, for example, a correction rect. */
- (CGRect)firstRectForRange:(UITextRange *)range{
     NSLog(@"Unimplemented - firstRectForRange:");
    return CGRectMake(0, 0, 0, 0);
}
- (CGRect)caretRectForPosition:(UITextPosition *)position{
    NSLog(@"Unimplemented - caretRectForPosition:");
    return CGRectMake(0, 0, 0, 0);
}

- (NSArray *)selectionRectsForRange:(UITextRange *)range{
    return @[];
}

/* Hit testing. */
- (UITextPosition *)closestPositionToPoint:(CGPoint)point{
    NSLog(@"Unimplemented - closestPositionToPoint:");
    return nil;    
}
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range{
    NSLog(@"Unimplemented - closestPositionToPoint:withinRange");
    return nil;    
}
- (UITextRange *)characterRangeAtPoint:(CGPoint)point{
    NSLog(@"Unimplemented - characterRangeAtPoint:");
    return nil;        
}


#pragma mark UIKeyBoard implementation

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void) showKeyboard{
    [self becomeFirstResponder];
}

-(void) hideKeyboard{
    [self resignFirstResponder];
    [self clearSelectionLayers];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [self.window convertRect:kbRect fromWindow:nil];
    _keyboardRect = [self convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, _keyboardRect.size.height, 0.0); 
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;

    [self scrollToCursor];
    NSLog(@"beginEdit");
    [TestFlight passCheckpoint:@"BeginEdit"];
    
    for (id<PTCodeViewDelegate> delegate in _codeViewDelegates){
        if ([delegate respondsToSelector:@selector(keyboardDidShow:)]){
            [delegate keyboardDidShow:notification];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)notification
{
    _keyboardRect = CGRectNull;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    NSLog(@"endEdit");
    [TestFlight passCheckpoint:@"EndEdit"];
    
    for (id<PTCodeViewDelegate> delegate in _codeViewDelegates){
        if ([delegate respondsToSelector:@selector(keyboardWillHide:)]){
            [delegate keyboardWillHide:notification];
        }
    }
}

// If the cursor is hidden by keyboard, scroll so that it is visible with a few extra lines
-(void) scrollToCursor
{
    if (!CGRectIsNull(_keyboardRect)) {

        CGRect displayRect = self.frame;
        displayRect.origin.y += self.contentOffset.y;
        displayRect.size.height -= _keyboardRect.size.height;  
        
        CGRect cursorRect = self.cursorLayer.frame;
        cursorRect = [self convertRect:cursorRect toView:self];
        // enlarge the 'cursor' rect to make sure we have a couple lines visible on each side
        cursorRect.origin.y -= (cursorRect.size.height * _numberOfExtraScrollLines);
        cursorRect.size.height += (cursorRect.size.height * (_numberOfExtraScrollLines*2));        
        
        if (!CGRectContainsRect(displayRect, cursorRect)) {
            [self scrollRectToVisible:cursorRect animated:YES];
        }
    }
}

- (void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer;
{
    if (deltaY != 0)
    {
        self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height+deltaY);
    }
    
    [self updateLayersByYOffset:deltaY andLineNumOffset:deltaLineNums startingAfterLayer:updatedLayer withPriorityLength:(self.frame.size.height * _numberOfScreensToBuffer)];
}

- (void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer withPriorityLength:(float)priorityLength
{
    if (updatedLayer && (deltaY != 0 || deltaLineNums != 0))
    {
        BOOL    startShiftingLayers = NO;
        int     prevLayerIndex = -1;
        float   currentUpdateLength = 0.f;
        
        for (PTCodeLayer* layer in _layerArray)
        {            
            if (priorityLength > 0 && currentUpdateLength >= priorityLength)
            {
                if (prevLayerIndex >= 0)
                {
                    PTCodeLayer* prevLayer = [_layerArray objectAtIndex:prevLayerIndex];
                    [_operationQueue addOperation:[AsyncShiftLayerOperation operationWithScrollView:self updateLayersByYOffset:deltaY andLineNumOffset:deltaLineNums startingAfterLayer:prevLayer]];
                }
                
                return;
            }
            
            if (layer == updatedLayer)
            {
                startShiftingLayers = YES;
                continue;
            }
            
            if (startShiftingLayers)
            {
                if (deltaY != 0)
                {
                    layer.frame = CGRectMake(layer.frame.origin.x, (layer.frame.origin.y + deltaY), layer.frame.size.width, layer.frame.size.height);
                }
                
                if (deltaLineNums != 0)
                {
                    layer.startingLineNum += deltaLineNums;                    
                }
                
                //draw all the layers for now. will want to the non-visible ones asynchronously in the 'future'
                [layer setNeedsDisplay];
                
                currentUpdateLength += layer.frame.size.height;
            }
            
            prevLayerIndex++;   
        }
    }
}

@end

/////////////////////////////////////////////////////////////////////////////
// MARK: - Async Operations
/////////////////////////////////////////////////////////////////////////////
@implementation AsyncShiftLayerOperation

-(id)init
{
	// Can only create instance with scroll view and data
	[NSException raise:NSInternalInconsistencyException format:@"%@: must be initialized with a scroll view and data", NSStringFromClass([self class])];
	return nil;
}

-(id)initWithScrollView:(PTCodeScrollView *)scrollView updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _deltaY = deltaY;
        _deltaLineNums = deltaLineNums;
        _updatedLayer = updatedLayer;
    }
    return self;
}

+(id)operationWithScrollView:(PTCodeScrollView *)scrollView updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer
{
    return [[self alloc] initWithScrollView:scrollView updateLayersByYOffset:deltaY andLineNumOffset:deltaLineNums startingAfterLayer:updatedLayer];
}

-(void)main
{
    [_scrollView updateLayersByYOffset:_deltaY andLineNumOffset:_deltaLineNums startingAfterLayer:_updatedLayer withPriorityLength:0];
}

@end




