//
//  LineOfCode.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LineOfCode.h"

@implementation LineOfCode

@synthesize attributedText = _attributedText;
@synthesize startIndexAtTypesetting = _startIndexAtTypesetting;

@synthesize numDisplayLines = _numDisplayLines;
@synthesize lineRef = _lineRef;
@synthesize lineNum = _lineNum;
@synthesize displayRect = _frame;

@synthesize needsRedraw = _needsRedraw;
@synthesize needsLayout = _needsLayout;

-(void) commonInit
{
    _needsLayout = true;
    _needsRedraw = true;
    _numDisplayLines = 0;
    _startIndexAtTypesetting = -1;
}


-(id) initWithAttributedString:(CFAttributedStringRef)text
{
    self = [super init];
    
    if (self)
    {
        [self commonInit];        
        self.attributedText = text;                        
    }
    
    return self;
}

-(id) initWithAttributedString:(CFAttributedStringRef)text typsetterOffset:(NSInteger)offset andLine:(CTLineRef)line
{
    self = [super init];
    
    if (self)
    {
        [self commonInit];  
        
        self.attributedText = text;
        _startIndexAtTypesetting = offset;

        self.lineRef = line;
        self.numDisplayLines = 1;
    }
    
    return self;
}


-(id) initWithAttributedString:(CFAttributedStringRef)text typsetterOffset:(NSInteger)offset andLineArray:(CFArrayRef)array
{
    self = [super init];
    
    if (self)
    {
        [self commonInit];
        
        self.attributedText = text;
        _startIndexAtTypesetting = offset;
        
        self.lineRef = array;
        self.numDisplayLines = CFArrayGetCount(array);
    }
    
    return self;
}

-(void) dealloc
{
    CFRelease(_attributedText);
    CFRelease(_lineRef);
}

-(void) setAttributedText:(CFAttributedStringRef)attributedText
{
    if (attributedText != _attributedText)
    {
        if (_attributedText != NULL)
        {
            CFRelease(_attributedText);
            _attributedText = NULL;
        }
        
        _attributedText = CFRetain(attributedText);
    }
}

-(void) setLineRef:(CFTypeRef)lineRef
{
    if (lineRef != _lineRef)
    {
        if (_lineRef != NULL)
        {
            CFRelease(_lineRef);
            _lineRef = NULL;
        }
        
        _lineRef = CFRetain(lineRef);
        
        if (lineRef != NULL)
        {
            CFTypeID id = CFGetTypeID(lineRef);            

            if (id == CTLineGetTypeID())
            {                                
                self.numDisplayLines = 1;
            }
            else if (id == CFArrayGetTypeID())
            {
                self.numDisplayLines = CFArrayGetCount(lineRef);
            }
        }        
        else
        {
            self.numDisplayLines = 0;
        }
    }    
}

-(NSString *) description
{
    return (__bridge NSString*)CFAttributedStringGetString(_attributedText);
}


@end
