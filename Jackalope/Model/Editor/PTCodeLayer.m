//
//  PTFrame.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTCodeLayer.h"

@implementation PTCodeLayer

@synthesize startingLineNum = _startingLineNum;
@synthesize suggestedLineLimit = _suggestedLineLimit;
@synthesize cursorView = _cursorView;
@synthesize selection = _selection;

/////////////////////////////////////////////////////////////////////////////
// MARK: - Initialization
/////////////////////////////////////////////////////////////////////////////
- (void)commonInit
{    
    _leftColumnWidth = 30;
    _leftGutterWidth = 6;
    _leftCodeOffset = _leftColumnWidth + _leftGutterWidth;
    _lineHeight = 25;

    _startingLineNum = 0;
    _suggestedLineLimit = 60;
    
    _newlineCharSet = [NSCharacterSet newlineCharacterSet];
}

- (id)init
{
    self = [super init];    
    if (self) {[self commonInit];}
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];    
    if (self) {[self commonInit];}
    return self;
}

- (id)initWithLinesOfCode:(NSArray*)LocArray
{
    self = [super init];    
    if (self) {
        [self commonInit];
        _locArray = [LocArray mutableCopy];
        [self loadAttributedString:nil];
    }
    return self;    
}

- (id)initWithLinesOfCode:(NSArray*)LocArray andAttributedString:(NSAttributedString*)attributedString
{
    self = [super init];    
    if (self) {
        [self commonInit];
        _locArray = [LocArray mutableCopy];
        [self loadAttributedString:attributedString];
    }
    return self;    
}

-(void) updateLine:(LineOfCode*) updatedLine
{
    for (LineOfCode* loc in _locArray)
    {
        if (loc == updatedLine)
        {
            [self layoutLoc:loc];
            [self setNeedsDisplay];
            
            break;
        }
    }
}

-(void) insertLine:(LineOfCode*) newLine afterLine:(LineOfCode*) exitingLine;
{
    NSInteger locIndex = 0;
    BOOL found = NO;
    
    for (LineOfCode* loc in _locArray)
    {
        locIndex++;
        
        if (loc == exitingLine)
        {
            if (locIndex == [_locArray count]){
                [_locArray addObject:newLine];
            }
            else
            {
                [_locArray insertObject:newLine atIndex:locIndex];
            }
            
            found = YES;
            break;
        }
    }
    
    CGRect oldRect = exitingLine.displayRect;    
    newLine.displayRect = CGRectMake(oldRect.origin.x, (oldRect.origin.y + (exitingLine.numDisplayLines * _lineHeight)), oldRect.size.width, (newLine.numDisplayLines * _lineHeight));
    
    [self layoutLoc:newLine];
    [self needsDisplay];
}


-(void) removeLine:(LineOfCode*) line
{
    [self updateLineHeightsBy:(-1*line.numDisplayLines) startingAtLine:line];
    [_locArray removeObject:line];
    [self needsDisplay];
    [self display];
}

-(void)layoutLoc:(LineOfCode*)loc
{
    // create frame for the entire code document
    CTFramesetterRef fullFramesetter = CTFramesetterCreateWithAttributedString(loc.attributedText);
    loc.startIndexAtTypesetting = 0;
    
    CGRect bigRect = CGRectMake((self.bounds.origin.x + _leftCodeOffset), self.bounds.origin.y, (self.bounds.size.width - _leftCodeOffset), (self.bounds.size.height *1000));
    CGMutablePathRef path = CGPathCreateMutable();        
    CGPathAddRect(path, NULL, bigRect);    
    CTFrameRef fullFrame = CTFramesetterCreateFrame(fullFramesetter,CFRangeMake(0,0), path, NULL);
    
    CFArrayRef displayLines = CTFrameGetLines(fullFrame);
    CFIndex lineCount = CFArrayGetCount(displayLines);    
    NSInteger deltaLineCount = (lineCount - loc.numDisplayLines);
        
    if (lineCount == 1)
    {
        loc.lineRef = CFArrayGetValueAtIndex(displayLines, 0);
    }
    else if (lineCount > 1)
    {
        loc.lineRef = displayLines;
    }
    
    [self updateLineHeightsBy:deltaLineCount startingAtLine:loc];
}

-(void) updateLineHeightsBy:(NSInteger)deltaRows startingAtLine:(LineOfCode*) updatedLoc
{
    if (deltaRows == 0)
    {
        return;
    } 
    
    CGFloat deltaHeight = deltaRows*_lineHeight;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (self.frame.size.height + deltaHeight));
    
    BOOL startUpdating = NO;        
    for (LineOfCode* loc in _locArray)
    {
        if (loc == updatedLoc)
        {
            CGRect rect = loc.displayRect;
            loc.displayRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, (rect.size.height + deltaHeight));
            startUpdating = YES;
            continue;
        }
        
        if (startUpdating)
        {
            CGRect rect = loc.displayRect;
            loc.displayRect = CGRectMake(rect.origin.x, (rect.origin.y+deltaHeight), rect.size.width, rect.size.height);
        }
    }
}

/////////////////////////////////////////////////////////////////////////////
// MARK: - Drawing
/////////////////////////////////////////////////////////////////////////////
//    When writing your layout code, be sure to test your code in the following ways:
//    -Change the orientation of your views to make sure the layout looks correct in all supported interface orientations.    
//    -Make sure your code responds appropriately to changes in the height of the status bar. (i.e. when you are on a call

-(NSInteger)loadAttributedString:(NSAttributedString*)attributedText
{
    CFAttributedStringRef attrCode;
    
    if (attributedText)
    {
        attrCode = (__bridge CFAttributedStringRef)attributedText;
        CFRetain(attrCode);
    }
    else
    {
        attrCode =  [self copyAttributedText];
    }        
    
    if (!attrCode)
    {
        // if there is no code to lay out so you don't gotta do nothing
        return 0;
    }
    
    // create frame for the entire code document
    CTFramesetterRef fullFramesetter = CTFramesetterCreateWithAttributedString(attrCode);
    CGRect bigRect = CGRectMake((self.bounds.origin.x + _leftCodeOffset), self.bounds.origin.y, (self.bounds.size.width - _leftCodeOffset), (self.bounds.size.height *1000));
    CGMutablePathRef path = CGPathCreateMutable();        
    CGPathAddRect(path, NULL, bigRect);    
    CTFrameRef fullFrame = CTFramesetterCreateFrame(fullFramesetter,CFRangeMake(0,0), path, NULL);
    
    //iterate through all the lines and setup the 'masterArray'
    CFArrayRef displayLines = CTFrameGetLines(fullFrame);
    CFIndex lineCount = CFArrayGetCount(displayLines);    
    _locArray = [[NSMutableArray alloc] initWithCapacity:lineCount];
    
    CFMutableArrayRef tempLineArray = NULL;
    CFRange tempRange = CFRangeMake(0,0);        

    CFIndex     currentIndex = 0;
    CTLineRef   currentLine = NULL;
    CFRange     currentLineRange = CFRangeMake(0, 0);
    
    // want to loop through either all the display lines or until we reach the suggested LOC limit
    while (attrCode && (currentIndex < lineCount) && ([_locArray count] < _suggestedLineLimit))
    {
        currentLine = CFArrayGetValueAtIndex(displayLines, currentIndex);                    
        currentLineRange = CTLineGetStringRange(currentLine);
        CFAttributedStringRef lineString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attrCode, currentLineRange);
        
        CFStringRef str = CFAttributedStringGetString(lineString);
        UniChar lastChar = CFStringGetCharacterAtIndex(str, (CFStringGetLength(str)-1));
        
        if ([_newlineCharSet characterIsMember:lastChar] || (currentIndex == lineCount-1))
        {            
            LineOfCode *loc = nil;
            
            if (tempLineArray == NULL)
            {                    
                loc = [[LineOfCode alloc] initWithAttributedString:lineString typsetterOffset:currentLineRange.location andLine:currentLine];                                       
            }
            else
            {
                // this is a bit awkward but I wanted to assume that most lines wouldn't wrap                    
                CFArrayAppendValue(tempLineArray, currentLine);
                tempRange.length += currentLineRange.length;
                
                CFRelease(lineString);
                lineString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attrCode, tempRange);
                
                loc = [[LineOfCode alloc] initWithAttributedString:lineString typsetterOffset:tempRange.location andLineArray:tempLineArray];
                
                CFRelease(tempLineArray);
                tempLineArray = NULL;
            }
            
            if (loc)
            {
                [_locArray addObject:loc]; 
                loc.lineNum = [_locArray count];
            }
        }
        else
        {
            if (tempLineArray == NULL)
            {
                tempLineArray = CFArrayCreateMutable(kCFAllocatorDefault, 2, &kCFTypeArrayCallBacks);
                tempRange = CFRangeMake(currentLineRange.location,0);
            }
            
            CFArrayAppendValue(tempLineArray, currentLine);
            tempRange.length += currentLineRange.length;
        }            
        
        CFRelease(lineString); 
        currentIndex += 1;
    }
    
    if (currentLine != NULL)
    {
        CTLineGetTypographicBounds(currentLine, &_ascent, &_descent, &_leading);
        _lineHeight = (_ascent+_descent+_leading);        
    }    
    
    CGRect codeFrame = self.frame;
    codeFrame.size.height = (currentIndex * _lineHeight);
    [self setFrame:codeFrame];
            
    CFRelease(fullFramesetter);
    CFRelease(fullFrame);
    CFRelease(path);
    CFRelease(attrCode);
    
    return (currentLineRange.location + currentLineRange.length);
}

-(void)drawInContext:(CGContextRef)ctx{             
    CGContextSaveGState(ctx);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);                
    
    CFTypeID lineType = CTLineGetTypeID();
    CFTypeID arrayType = CFArrayGetTypeID();
    
    CGFloat y = (self.bounds.origin.y + (self.bounds.size.height-_lineHeight));
    
    CGRect leftColumnRect = {self.frame.origin.x, self.frame.origin.y, _leftColumnWidth, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 220/255.f, 220/255.f, 220/255.f, 1);
    CGContextFillRect(ctx, leftColumnRect);        
    
    CGRect leftColumnBorder = {(self.frame.origin.x + _leftColumnWidth), self.frame.origin.y, 1, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 140/255.f, 140/255.f, 140/255.f, 1);
    CGContextFillRect(ctx, leftColumnBorder);        
    
    long int lineIndex = 0;
    for (LineOfCode* loc in _locArray)
    {                    
        // line number setup
        NSMutableAttributedString* nsNumString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",(lineIndex+_startingLineNum)]] mutableCopy];
        [nsNumString setFont:[UIFont fontWithName:@"Courier" size:12]];
        [nsNumString setTextColor:[UIColor colorWithRed:112/255.f green:112/255.f blue:112/255.f alpha:1]];
        CFAttributedStringRef lineNumString = (__bridge CFAttributedStringRef)nsNumString;        
        CTLineRef gutterLine = CTLineCreateWithAttributedString(lineNumString);
        float a,d,l;
        double width = CTLineGetTypographicBounds(gutterLine,&a,&d,&l);
        
        CFTypeRef lineRef = loc.lineRef;
        CFTypeID id = CFGetTypeID(lineRef);            
        
        // single display line
        if (lineRef != NULL && id == lineType)
        {                                
            CGContextSetTextPosition(ctx, (self.bounds.origin.x + (_leftColumnWidth - width - 2)), y+0.5);
            CTLineDraw(gutterLine, ctx);
            CFRelease(gutterLine);
            
            CGContextSetTextPosition(ctx, (self.bounds.origin.x + _leftCodeOffset), y);
            CTLineDraw((CTLineRef)lineRef, ctx);
            loc.displayRect = CGRectMake(self.bounds.origin.x, ((self.bounds.size.height-y) - _lineHeight), self.bounds.size.width, _lineHeight);
            
            y -= _lineHeight;
        }
        
        // multiple display lines for this single line of code
        else if (lineRef != NULL && id == arrayType)
        {
            CFIndex lineCount = CFArrayGetCount((CFArrayRef)lineRef);
            
            // draw the first line with the line number
            if (lineCount > 0)
            {
                CGContextSetTextPosition(ctx, (self.bounds.origin.x + (_leftColumnWidth - width - 2 )), y-(_lineHeight - (a+d))/2);
                CTLineDraw(gutterLine, ctx);
                CFRelease(gutterLine);
                
                CGContextSetTextPosition(ctx, (self.bounds.origin.x + _leftCodeOffset), y);
                CTLineDraw((CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lineRef, 0), ctx);
                loc.displayRect = CGRectMake(self.bounds.origin.x, ((self.bounds.size.height-y) - _lineHeight), self.bounds.size.width, _lineHeight);
                
                y -= _lineHeight;
            }
            
            // draw the remainder of the display lines without a line number
            if (lineCount > 1)
            {                    
                for (int wrapIndex = 1; wrapIndex < lineCount; wrapIndex++)
                {
                    CGContextSetTextPosition(ctx, (self.bounds.origin.x + _leftCodeOffset), y);
                    CTLineDraw((CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lineRef, wrapIndex), ctx);
                    loc.displayRect = CGRectMake(loc.displayRect.origin.x, loc.displayRect.origin.y, loc.displayRect.size.width, (loc.displayRect.size.height+_lineHeight));
                    
                    y -= _lineHeight;
                }
            }
        }
        
        lineIndex +=1;        
    }                                        
    
    CGContextRestoreGState(ctx);                    
}


/////////////////////////////////////////////////////////////////////////////
// MARK: - Touch/Selection Management
/////////////////////////////////////////////////////////////////////////////
- (PTTextPosition *) closestPositionToPoint:(CGPoint)point
{
    point.x = (point.x - _leftCodeOffset);
    point.y = (point.y - self.frame.origin.y);
    
    for (LineOfCode* loc in _locArray)
    {        
        NSInteger index = kCFNotFound;        
        CGRect displayRect = loc.displayRect;
        
        if ((displayRect.origin.y <= point.y) && ((displayRect.origin.y + displayRect.size.height) >= point.y))
        {
            if (loc.numDisplayLines == 1)
            {
                index = CTLineGetStringIndexForPosition((CTLineRef)loc.lineRef, point);        
            }
            else
            {                
                for (int i=0; i < loc.numDisplayLines; i++)
                {
                    NSInteger lineMaxY = (displayRect.origin.y + (i*_lineHeight) + _lineHeight) ;
                    if (lineMaxY >= point.y)
                    {
                        CTLineRef wrapLine = CFArrayGetValueAtIndex((CFArrayRef)loc.lineRef, i);
                        NSInteger wrapIndex = CTLineGetStringIndexForPosition(wrapLine, point);
                        if (wrapIndex != kCFNotFound)
                        {
                            index = wrapIndex;
                            break;
                        }
                    }
                }
            }
        }
        
        // if the point was found. make sure that the position is to the the left of the newline char
        if (index != kCFNotFound)
        {
            NSInteger lineIndex = (index - loc.startIndexAtTypesetting);
            CFStringRef lineString = CFAttributedStringGetString(loc.attributedText);
            CFIndex lineLength = CFStringGetLength(lineString);
            
            // If the user touches at the end of the line, 
            // we don't want to set the cursor on the right side of the newLineChar

            if (lineIndex > 0 && lineIndex == lineLength)
            {
                lineIndex -= 1;
            }
                        
            return [PTTextPosition positionInLine:loc WithIndex:lineIndex];
        }
    }
    
    return nil;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    CATransition *theAnimation=nil;
    if ([event isEqualToString:@"contents"])
    {
        theAnimation = [CAAnimation animation];
        theAnimation.duration = 0.0;
    }        
    
    return theAnimation;
}


-(CGRect) createCursorRectForPosition:(PTTextPosition*)pos
{        
    LineOfCode* loc = pos.loc;
    NSInteger actualIndex = (pos.index + loc.startIndexAtTypesetting);
    CGFloat xPos = 0.0;
    
    CGRect cursorRect = CGRectMake(_leftCodeOffset, (loc.displayRect.origin.y + _descent), 0, (_ascent + _descent));
            
    if (loc.numDisplayLines == 1)
    {
        xPos = CTLineGetOffsetForStringIndex(loc.lineRef, actualIndex, NULL);
    }
    else if (loc.numDisplayLines > 1)
    {
        // we want to loop backwards through the line because calling the lineOffset function will always return an index.
        // so we want to start with the last display line because it knows nothing of the earlier line's strings
        for (int i = (loc.numDisplayLines -1); i >=0 ; i--)
        {
            xPos = CTLineGetOffsetForStringIndex(CFArrayGetValueAtIndex(loc.lineRef, i), actualIndex, NULL);    
            if (xPos > 0.0){
                cursorRect.origin.y += (i * _lineHeight);
                break;
            }
        }
    }
    
    cursorRect.origin.x += xPos;
    cursorRect.size.width = 1.5;
            
    return cursorRect;
}

-(void) setSelection:(PTTextRange *)selection
{
    _selection = selection;
    PTTextPosition* pos = (PTTextPosition*)selection.start;

    [_cursorView stopBlinking];
    [_cursorView removeFromSuperlayer];
    
    _cursorView.frame = [self createCursorRectForPosition:pos];    
    [self addSublayer:_cursorView];    
    [_cursorView startBlinking];
    
}

-(void) setStartingLineNum:(NSInteger)startingLineNum
{
    _startingLineNum = startingLineNum;
}

-(CFAttributedStringRef) copyAttributedText
{
    CFMutableAttributedStringRef fullText = CFAttributedStringCreateMutable(kCFAllocatorDefault,0);

    for (LineOfCode* loc in _locArray)        
    {
        CFAttributedStringReplaceAttributedString(fullText,CFRangeMake(CFAttributedStringGetLength(fullText), 0),loc.attributedText);
    }
    
    // TODO potential memory leak here
    // not sure if it is correct to call CFRelease on fulltext
    
    return fullText;
}

-(NSRange) lineNumRange
{
    return NSMakeRange(_startingLineNum, [_locArray count]);
}

// Non-mutable accessor for the underlying line array
- (NSArray*) locArray
{
    return _locArray;
}

@end
