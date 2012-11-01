//
//  PTCodeScrollView.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTCodeScrollView.h"
#import <CoreText/CoreText.h>
#import "LineOfCode.h"

#import "PTTextPosition.h"
#import "PTTextRange.h"

// We use a tap gesture recognizer to allow the user to tap to invoke text edit mode
@interface PTCodeScrollView() <UIGestureRecognizerDelegate>

- (void) tap:(UITapGestureRecognizer *)tap;
- (void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer  withPriorityLength:(float)priorityLength;

-(void) registerForKeyboardNotifications;

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
    
    [self registerForKeyboardNotifications];
    
    _keyboardRect = CGRectNull;
    _newlineCharSet = [NSCharacterSet newlineCharacterSet];
    _layerArray = [[NSMutableArray alloc] initWithCapacity:1];
    _cursorView = [[PTCursorView alloc] init];

    _maxFrameSize               = 50;
    _numberOfScreensToBuffer    = 3;
    _numberOfExtraScrollLines   = 2;
    
    _whiteSpaceRegex = [NSRegularExpression 
                        regularExpressionWithPattern:@"^[\t ]*"
                        options:0
                        error:NULL];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    _textInputDelegates = [[NSMutableArray alloc] initWithCapacity:1];
    
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
    _decorator = [[DecoratorCollection getInstance] decoratorForFileName:code.fileName];        
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
        currentFrame.origin.y = ceilf(currentFrame.origin.y);
        
        if ((fullLength - currentIndex) < loadSize){
            loadSize = (fullLength - currentIndex);
        }
        
        PTCodeLayer* currentLayer = [[PTCodeLayer alloc] init];
        currentLayer.frame = currentFrame;
        currentLayer.contentsScale = [UIScreen mainScreen].scale;
        currentLayer.cursorView = _cursorView;
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

#pragma mark Custom user interaction

-(void) setSelectionAtPoint:(CGPoint)point
{
    NSInteger frameIndex = 0;
    for (PTCodeLayer* layer in _layerArray)
    {
        if ((point.y >= layer.frame.origin.y) && (point.y <= (layer.frame.origin.y + layer.frame.size.height)))
        {
            _currentLayer = layer;
            PTTextPosition* pos = [layer closestPositionToPoint:point];
            PTTextRange* range = [[PTTextRange alloc] initWithStartPosition:pos andEndPosition:pos];

            self.selection = range;
            layer.selection = range;
            
            return;
        }
        
        frameIndex += 1;
    }    
}
  
- (void)tap:(UITapGestureRecognizer *)tap{
    if (![self isFirstResponder]) { 
		// Inform controller that we're about to enter editing mode
		//[self.editableCoreTextViewDelegate editableCoreTextViewWillEdit:self];
		// Flag that underlying SimpleCoreTextView is now in edit mode
        //_textView.editing = YES;
		// Become first responder state (which shows software keyboard, if applicable)
        [self showKeyboard];
    }
        
    // Find and update insertion point    
    [self selectionWillChange];
    [self setSelectionAtPoint:[tap locationInView:_codeEditor]];    
    [self selectionDidChange];            
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
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
    if (!text || ([text length] == 0))
    {
        return;
    }

    // need to split up the inserted text to accommodate any newline characters
    __block PTTextPosition* currentPos = [((PTTextPosition*)self.selection.start) copy];    
    if (!currentPos)
    {
        return;
    }
    
    [self textWillChange];
    
    NSInteger initLocCount = [_currentLayer.locArray count];
    CGFloat initLayerHeight = _currentLayer.frame.size.height;    
    
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByLines usingBlock:
        ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {                        

            NSMutableString*    lineString  = [(__bridge NSString*)CFAttributedStringGetString(currentPos.loc.attributedText) mutableCopy];                        
            PTTextPosition*     nextPos     = nil;
            LineOfCode*         newLoc      = nil;
            
            if (substringRange.length > 0)
            {                
                [lineString insertString:substring atIndex:currentPos.index];
                currentPos.index += substringRange.length;
            }
       
            // if this substring isn't at the end up the insertText there must bea newline up next
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

                newLoc = [[LineOfCode alloc] initWithAttributedString:(__bridge CFAttributedStringRef)newLine];            
                nextPos = [PTTextPosition positionInLine:newLoc WithIndex:indentationRange.length];
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
        self.selection = [[PTTextRange alloc] initWithStartPosition:currentPos andEndPosition:currentPos];
        _currentLayer.selection = self.selection;
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
    PTTextPosition* currentPos = (PTTextPosition*)self.selection.start;
    if (!currentPos)
    {
        return;
    }
    
    [self textWillChange];
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
        _currentLayer.selection = self.selection;
    }
    
    // Special Case. Need to add this line's text to the previous line (if there is one)
    else
    {
        NSArray* currentLocArray = _currentLayer.locArray;
        LineOfCode* oldLoc = currentPos.loc;
        LineOfCode* newLoc = nil;
        NSInteger locIndex = [currentLocArray indexOfObject:oldLoc];        
        
        // if this isn't the first line in the layer. we want to update it's predecessor
        if (locIndex > 0){
            CGFloat oldHeight = _currentLayer.frame.size.height;
            [_currentLayer removeLine:oldLoc];

            CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);            
            [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:(-1) startingAfterLayer:_currentLayer];

            newLoc = [currentLocArray objectAtIndex:(locIndex-1)];

        }
        // if this is the first line in the layer, we need to pull up the last loc in the previous frame
        else
        {
            NSInteger currentLayerIndex = [_layerArray indexOfObject:_currentLayer];
            
            // if there are no previous loc's or layers we don't do anything for the delete key
            if (currentLayerIndex > 0)
            {
                CGFloat oldHeight = _currentLayer.frame.size.height;                
                [_currentLayer removeLine:oldLoc];

                CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - oldHeight);                
                [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:(-1) startingAfterLayer:_currentLayer];
                
                _currentLayer = [_layerArray objectAtIndex:(currentLayerIndex-1)];
                newLoc = _currentLayer.locArray.lastObject;
            }
        }

        if (newLoc)
        {
            // strip the newline off this guy. there should already be one on the line above
            [lineString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [lineString length])];
            PTTextPosition* newPos = [PTTextPosition positionInLine:newLoc WithIndex:(CFAttributedStringGetLength(newLoc.attributedText)-1)];
            self.selection = [[PTTextRange alloc] initWithStartPosition:newPos andEndPosition:newPos];
            _currentLayer.selection = self.selection;
            [self insertText:lineString andMoveCursor:NO];
        }
    }
    
    [self scrollToCursor];
    [self textDidChange];
}

-(void) addTextInputDelegate:(id<UITextInputDelegate>)delegate{
    [_textInputDelegates addObject:delegate];
}
-(void) removeTextInputDelegate:(id<UITextInputDelegate>)delegate{
    [_textInputDelegates removeObject:delegate];
}
-(void) textDidChange{
    [self.inputDelegate textDidChange:self];
    
    for (id<UITextInputDelegate> delegate in _textInputDelegates){
        [delegate textDidChange:self];
    }
}
-(void) textWillChange{
    [self.inputDelegate textWillChange:self];
    
    for (id<UITextInputDelegate> delegate in _textInputDelegates){
        [delegate textWillChange:self];
    }    
}
-(void) selectionDidChange{
    [self.inputDelegate selectionDidChange:self];
    
    for (id<UITextInputDelegate> delegate in _textInputDelegates){
        [delegate selectionDidChange:self];
    }        
}
-(void) selectionWillChange{
    [self.inputDelegate selectionWillChange:self];
    
    for (id<UITextInputDelegate> delegate in _textInputDelegates){
        [delegate selectionWillChange:self];
    }    
}

#pragma mark UITextInputTraits methods
-(UITextAutocapitalizationType) autocapitalizationType  {return UITextAutocapitalizationTypeNone;}
-(UITextAutocorrectionType)     autocorrectionType      {return UITextAutocorrectionTypeNo;}
-(UITextSpellCheckingType)      spellCheckingType       {return UITextSpellCheckingTypeNo;}

#pragma mark UITextInput methods
- (NSString *)textInRange:(UITextRange *)range{
    NSLog(@"Unimplemented - textInRange:");
    return nil;
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
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void) showKeyboard{
    [self becomeFirstResponder];
}

-(void) hideKeyboard{
    [self resignFirstResponder];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardRect = [self convertRect:kbRect toView:nil];
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, _keyboardRect.size.height, 0.0); 
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;

    [self scrollToCursor];
    NSLog(@"beginEdit");
    [TestFlight passCheckpoint:@"BeginEdit"];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    _keyboardRect = CGRectNull;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    NSLog(@"endEdit");
    [TestFlight passCheckpoint:@"EndEdit"];
}

// If the cursor is hidden by keyboard, scroll so that it is visible with a few extra lines
-(void) scrollToCursor
{
    if (!CGRectIsNull(_keyboardRect)) {

        CGRect displayRect = self.frame;
        displayRect.origin.y += self.contentOffset.y;
        displayRect.size.height -= _keyboardRect.size.height;  
        
        CGRect cursorRect = _cursorView.frame;
        cursorRect = [self convertRect:cursorRect toView:self];
        cursorRect.origin.y += _currentLayer.frame.origin.y;
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




