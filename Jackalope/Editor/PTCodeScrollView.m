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

- (void)tap:(UITapGestureRecognizer *)tap;

@end


@implementation PTCodeScrollView

@synthesize inputDelegate;
@synthesize selection = _selection;
@synthesize code = _code;

/////////////////////////////////////////////////////////////////////////////
// MARK: - Initialization
/////////////////////////////////////////////////////////////////////////////

-(void) commonInit
{    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
    
    [self registerForKeyboardNotifications];
    
    _newlineCharSet = [NSCharacterSet newlineCharacterSet];
    _layerArray = [[NSMutableArray alloc] initWithCapacity:1];
    _cursorView = [[PTCursorView alloc] init];
    _maxFrameSize = 50;
    
    _whiteSpaceRegex = [NSRegularExpression 
                        regularExpressionWithPattern:@"^[\t ]*"
                        options:0
                        error:NULL];
    
    //self.contentMode = UIViewContentModeRedraw;
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
    if (!code || !(code.plainText))
    {
        return;
    }
    
    _code = code;    
    _decorator = [[DecoratorCollection getInstance] decoratorForFileName:code.fileName];        
    _layerArray = [[NSMutableArray alloc] init];
    [self resignFirstResponder];
    
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
        currentLayer.cursorView = _cursorView;
        currentLayer.suggestedLineLimit = 10;
        currentLayer.startingLineNum = currentLineNum;
        
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

#pragma mark Custom user interaction

// UIResponder protocol override - our view can become first responder to 
// receive user text input
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

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
  
// UIResponder protocol override - called when our view is being asked to resign 
// first responder state (in this sample by using the "Done" button)  
- (BOOL)resignFirstResponder
{
	// Flag that underlying SimpleCoreTextView is no longer in edit mode
    //_textView.editing = NO;	
	return [super resignFirstResponder];
}

- (void)tap:(UITapGestureRecognizer *)tap{
    if (![self isFirstResponder]) { 
		// Inform controller that we're about to enter editing mode
		//[self.editableCoreTextViewDelegate editableCoreTextViewWillEdit:self];
		// Flag that underlying SimpleCoreTextView is now in edit mode
        //_textView.editing = YES;
		// Become first responder state (which shows software keyboard, if applicable)
        [self becomeFirstResponder];
    }
    
    
    //[self.inputDelegate selectionWillChange:self];
        
    // Find and update insertion point
    
    [self setSelectionAtPoint:[tap locationInView:_codeEditor]];    
    
    
    // Let inputDelegate know selection has changed
    //[self.inputDelegate selectionDidChange:self];            
}

-(void)drawRect:(CGRect)rect
{
    float _leftColumnWidth = 25;
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
    }
    
    NSInteger deltaLocCount = ([_currentLayer.locArray count] - initLocCount);
    CGFloat deltaLayerHeight = (_currentLayer.frame.size.height - initLayerHeight);
    [self updateLayersByYOffset:deltaLayerHeight andLineNumOffset:deltaLocCount startingAtLayer:_currentLayer];
}

// UIKeyInput required method - Delete a character from the displayed text.
// Called by the text system when the user is invoking a delete (e.g. pressing
// the delete software keyboard key)
- (void)deleteBackward 
{
    PTTextPosition* currentPos = (PTTextPosition*)self.selection.start;
    NSMutableString* lineString = [(__bridge NSString*)CFAttributedStringGetString(currentPos.loc.attributedText) mutableCopy];    

    // Standard case. Just delete the character to the left of the cursor
    if (currentPos.index != 0)
    {            
        [lineString deleteCharactersInRange:NSMakeRange((currentPos.index-1), 1)];
        
        CGFloat oldHeight = _currentLayer.frame.size.height;
        currentPos.loc.attributedText = (__bridge CFAttributedStringRef)[_decorator decorateString:lineString];
        [_currentLayer updateLine:currentPos.loc];
        
        CGFloat deltaHeight = (_currentLayer.frame.size.height - oldHeight);
        [self updateLayersByYOffset:deltaHeight andLineNumOffset:0 startingAtLayer:_currentLayer];
        
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
            CGFloat deltaHeight = (_currentLayer.frame.size.height - oldHeight);
            [self updateLayersByYOffset:deltaHeight andLineNumOffset:(-1) startingAtLayer:_currentLayer];

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
                CGFloat deltaHeight = (_currentLayer.frame.size.height - oldHeight);
                [self updateLayersByYOffset:deltaHeight andLineNumOffset:(-1) startingAtLayer:_currentLayer];
                
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
    
}


#pragma mark UIKeyBoard implementation

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0); self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
        
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect displayRect = self.frame;
    displayRect.size.height -= kbSize.height;  
    
    CGRect cursorRect = _cursorView.frame;
    cursorRect.origin.y += _currentLayer.frame.origin.y;
    
    if (!CGRectContainsPoint(displayRect, cursorRect.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, cursorRect.origin.y-kbSize.height);
        [self setContentOffset:scrollPoint animated:YES];
    }    
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

-(void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAtLayer:(PTCodeLayer*) updatedLayer;
{
    if (updatedLayer && (deltaY != 0 || deltaLineNums != 0))
    {
        BOOL startShiftingLayers = NO;
        for (PTCodeLayer* layer in _layerArray)
        {
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
            }
        }
    }
    
    // have to update the scroll view size as well
    if (deltaY != 0)
    {
        self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height+deltaY);
    }

}

@end