//
//  PTFrame.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTCodeLayer.h"
#import "PTSelectionLayer.h"

@implementation PTCodeLayer

@synthesize startingLineNum = _startingLineNum;
@synthesize suggestedLineLimit = _suggestedLineLimit;
@synthesize displayMode = _displayMode;

/////////////////////////////////////////////////////////////////////////////
// MARK: - Initialization
/////////////////////////////////////////////////////////////////////////////
- (void)commonInit
{    
    _leftColumnWidth = 28;
    _leftGutterWidth = 6;
    _leftCodeOffset = _leftColumnWidth + _leftGutterWidth;
    _lineHeight = 0;

    _startingLineNum = 0;
    _displayMode = EDITOR_DISPLAY_LINENUMS;
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

-(void) dealloc
{
    [_locArray removeAllObjects];
}

-(void) updateLine:(PTLineOfCode*) updatedLine
{
    for (PTLineOfCode* loc in _locArray)
    {
        if (loc == updatedLine)
        {
            [self layoutLoc:loc];
            [self setNeedsDisplay];
            
            break;
        }
    }
}

-(void) insertLine:(PTLineOfCode*) newLine afterLine:(PTLineOfCode*) existingLine;
{
    NSInteger locIndex = 0;
    BOOL found = NO;
    
    for (PTLineOfCode* loc in _locArray)
    {
        locIndex++;
        
        if (loc == existingLine)
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
    
    CGRect oldRect = existingLine.displayRect;    
    newLine.displayRect = CGRectMake(oldRect.origin.x, (oldRect.origin.y + (existingLine.numDisplayLines * _lineHeight)), oldRect.size.width, (newLine.numDisplayLines * _lineHeight));
    
    [self layoutLoc:newLine];
    [self needsDisplay];
}


-(void) removeLine:(PTLineOfCode*) line
{
    [self updateLineHeightsBy:(-1*line.numDisplayLines) startingAtLine:line];
    [_locArray removeObject:line];
    [self needsDisplay];
    [self display];
}

-(void)layoutLoc:(PTLineOfCode*)loc
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

-(void) updateLineHeightsBy:(NSInteger)deltaRows startingAtLine:(PTLineOfCode*) updatedLoc
{
    if (deltaRows == 0)
    {
        return;
    } 
    
    CGFloat deltaHeight = deltaRows*_lineHeight;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (self.frame.size.height + deltaHeight));
    
    BOOL startUpdating = NO;        
    for (PTLineOfCode* loc in _locArray)
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
        // there is no code to lay out so you don't gotta do nothing
        return 0;
    }
    
    // create frame for the entire code document
    CTFramesetterRef fullFramesetter = CTFramesetterCreateWithAttributedString(attrCode);
    //set the height impossibly high and we will calculate the actual height once we have layed the lines out
    CGRect bigRect = CGRectMake((self.bounds.origin.x + _leftCodeOffset), self.bounds.origin.y, (self.bounds.size.width - _leftCodeOffset), (100000)); 
    CGMutablePathRef path = CGPathCreateMutable();        
    CGPathAddRect(path, NULL, bigRect);    
    CTFrameRef fullFrame = CTFramesetterCreateFrame(fullFramesetter,CFRangeMake(0,0), path, NULL);
    
    //iterate through all the lines and setup the 'masterArray'
    CFArrayRef displayLines = CTFrameGetLines(fullFrame);
    CFIndex lineCount = CFArrayGetCount(displayLines);

    [_locArray removeAllObjects];
    _locArray = [[NSMutableArray alloc] initWithCapacity:lineCount];
    
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(fullFrame, CFRangeMake(0, lineCount), origins);        
    
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
        
        if ([_newlineCharSet characterIsMember:lastChar] || (currentIndex == lineCount-1)) //
        {            
            PTLineOfCode *loc = nil;
            
            if (tempLineArray == NULL) // we are at the end of a line and there are no other display lines that haven't been assigned
            {                    
                loc = [[PTLineOfCode alloc] initWithAttributedString:lineString typsetterOffset:currentLineRange.location andLine:currentLine];                                       
            }
            else // we are at the end of a visible line and we have multiple display lines to group together
            {
                CFArrayAppendValue(tempLineArray, currentLine);
                tempRange.length += currentLineRange.length;
                
                CFRelease(lineString);
                lineString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attrCode, tempRange);
                
                loc = [[PTLineOfCode alloc] initWithAttributedString:lineString typsetterOffset:tempRange.location andLineArray:tempLineArray];
                
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
    
    // draw the left column
    CGRect leftColumnRect = {0, 0, _leftColumnWidth, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 220/255.f, 220/255.f, 220/255.f, 1);
    CGContextFillRect(ctx, leftColumnRect);
    CGRect leftColumnBorder = {_leftColumnWidth, 0, 1, self.frame.size.height};
    CGContextSetRGBFillColor(ctx, 140/255.f, 140/255.f, 140/255.f, 1);
    CGContextFillRect(ctx, leftColumnBorder);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);   
    
    CGFloat y = self.bounds.origin.y;
    y += self.bounds.size.height; // CoreText draws bottom up so we need to set the drawing point at the bottom of the layer
    y -= (_lineHeight - _descent); // Lineheight-descent calculates the text baseline, which is where CoreText expects to start drawing
        
    long int lineIndex = 0;
    for (PTLineOfCode* loc in _locArray)
    {                    
        NSMutableAttributedString* nsGutterString;
        CFAttributedStringRef cfGutterString;
        CTLineRef gutterLine;
        
        // line number setup
        if (_displayMode == EDITOR_DISPLAY_LINENUMS)
        {
            nsGutterString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(lineIndex+_startingLineNum)]] mutableCopy];
        }
        else if (_displayMode == EDITOR_DISPLAY_DIFF)
        {
            nsGutterString = [[[NSAttributedString alloc] initWithString:@"•"] mutableCopy];
        }
        
        [nsGutterString setFont:[UIFont fontWithName:@"DroidSansMono" size:13]];
        [nsGutterString setTextColor:[UIColor colorWithRed:112/255.f green:112/255.f blue:112/255.f alpha:1]];
        cfGutterString = (__bridge CFAttributedStringRef)nsGutterString;        
        gutterLine = CTLineCreateWithAttributedString(cfGutterString);
        
        CFTypeRef lineRef = loc.lineRef;              
        
        // first display line
        if (lineRef != NULL && loc.numDisplayLines > 0)
        {                                
            CTLineRef codeLine;
            
            if (loc.numDisplayLines < 2)
            {
                codeLine = lineRef;
            }
            else
            {
                codeLine = (CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lineRef, 0);
            }
            
            float   gA,gD,gL;
            double  gWidth = CTLineGetTypographicBounds(gutterLine,&gA,&gD,&gL);
            float   cA, cD, cL;
            CTLineGetTypographicBounds(codeLine,&cA,&cD,&cL);

            CGContextSetTextPosition(ctx, self.bounds.origin.x + (_leftColumnWidth - gWidth - 2), y);
            CTLineDraw(gutterLine, ctx);
            CFRelease(gutterLine);
            
            CGContextSetTextPosition(ctx, (self.bounds.origin.x + _leftCodeOffset), y);            
            CTLineDraw((CTLineRef)codeLine, ctx);
            loc.displayRect = CGRectMake(self.bounds.origin.x, ((self.bounds.size.height-y) - _ascent), self.bounds.size.width, _lineHeight);
            
            y -= _lineHeight;
        }
        
        // multiple subsequent display lines for this single line of code
        if (lineRef != NULL && loc.numDisplayLines > 1)
        {
            for (int wrapIndex = 1; wrapIndex < loc.numDisplayLines; wrapIndex++)
            {
                CGContextSetTextPosition(ctx, (self.bounds.origin.x + _leftCodeOffset), y);
                CTLineDraw((CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lineRef, wrapIndex), ctx);
                loc.displayRect = CGRectMake(loc.displayRect.origin.x, loc.displayRect.origin.y, loc.displayRect.size.width, (loc.displayRect.size.height+_lineHeight));
                
                y -= _lineHeight;
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
    
    for (PTLineOfCode* loc in _locArray)
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
                        
            return [PTTextPosition positionInLayer:self InLine:loc WithIndex:lineIndex];
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

-(CGRect) createRectForPosition:(PTTextPosition*)pos
{
    if (!pos || !pos.loc || pos.index == NSUIntegerMax)
    {
        return CGRectMake(0, 0, 1, 11);
    }
    
    PTLineOfCode* loc = pos.loc;
    NSInteger actualIndex = (pos.index + loc.startIndexAtTypesetting);
    CGFloat xOffset = 0.0;
    CGFloat yOffset = 0.0;
    CTLineRef currentLine;

            
    if (loc.numDisplayLines == 1)
    {
        xOffset = CTLineGetOffsetForStringIndex(loc.lineRef, actualIndex, NULL);
        currentLine = loc.lineRef;
    }
    else if (loc.numDisplayLines > 1)
    {
        for (int i =0; i < loc.numDisplayLines ; i++)
        {
            currentLine = CFArrayGetValueAtIndex(loc.lineRef, i);
            CFRange currentLineRange = CTLineGetStringRange(currentLine);
            if (actualIndex >= currentLineRange.location && actualIndex < (currentLineRange.location + currentLineRange.length)){
                xOffset = CTLineGetOffsetForStringIndex(currentLine, actualIndex, NULL);
                yOffset = (i * _lineHeight);
                break;
            }
        }
    }

    float ascent,descent,leading;    
    CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
    CGFloat fudgeFactor = 0.5; // the rect looks just a little too tight on the line visually so I am artificially bumping it up

    return CGRectMake((_leftCodeOffset + xOffset), (self.frame.origin.y + loc.displayRect.origin.y + yOffset + fudgeFactor), 1, (ascent + descent + leading + fudgeFactor));
}

-(void) setStartingLineNum:(NSInteger)startingLineNum
{
    _startingLineNum = startingLineNum;
}

-(CFAttributedStringRef) copyAttributedText
{
    CFMutableAttributedStringRef fullText = CFAttributedStringCreateMutable(kCFAllocatorDefault,0);

    for (PTLineOfCode* loc in _locArray)        
    {
        CFAttributedStringReplaceAttributedString(fullText,CFRangeMake(CFAttributedStringGetLength(fullText), 0),loc.attributedText);
    }
    
    // TODO potential memory leak here
    // not sure if it is correct to call CFRelease on fulltext
    
    return fullText;
}

-(NSString*) fullText
{
    CFAttributedStringRef attrText = [self copyAttributedText];
    NSString* text = [(__bridge NSString*)CFAttributedStringGetString(attrText) copy];
    CFRelease(attrText);
    
    return text;
}

-(PTTextRange*) rangeForSearchString:(NSString*)searchText startingAtPosition:(PTTextPosition*)startOffset {
    NSRange searchRange;
    PTTextRange* result = nil;
    BOOL startSearching = startOffset ? false : true;
    
    for (PTLineOfCode* loc in _locArray)
    {
        if (!startSearching && (startOffset.loc != loc)){
            continue;
        } else if (!startSearching) {
            startSearching = YES;
            NSUInteger rangeLength = CFAttributedStringGetLength(loc.attributedText) - startOffset.index;
            searchRange = NSMakeRange(startOffset.index, rangeLength);
        } else {
            searchRange = NSMakeRange(0, CFAttributedStringGetLength(loc.attributedText));
        }
        
        NSString* text = [(__bridge NSString*)CFAttributedStringGetString(loc.attributedText) copy];
        NSRange resultRange = [text rangeOfString:searchText options:NSLiteralSearch range:searchRange];
        if (resultRange.location != NSNotFound) {
            PTTextPosition *startPosition = [PTTextPosition positionInLayer:self InLine:loc WithIndex:resultRange.location];
            PTTextPosition *endPosition = [PTTextPosition positionInLayer:self InLine:loc WithIndex:(resultRange.location+resultRange.length)];
            result = [PTTextRange rangeWithStartPosition:startPosition andEndPosition:endPosition];
            break;
        }
    }
    
    return result;
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
