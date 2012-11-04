//
//  PTTextRange.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTTextRange.h"
#import "PTTextPosition.h"

@implementation PTTextRange

@synthesize range = _range;

// Class method to create an instance with a given range
- (id)initWithStartPosition:(PTTextPosition *)startPosition andEndPosition:(PTTextPosition *)endPosition
{
    self = [super init];
    
    if (self)
    {
        _startPos = startPosition;
        _endPos = endPosition;
    }
    
    return self;
}

// UITextRange read-only property - returns start index of range
- (UITextPosition *)start
{
    return _startPos;
}

// UITextRange read-only property - returns end index of range
- (UITextPosition *)end
{
	return _endPos;
}

// UITextRange read-only property - returns YES if range is zero length
-(BOOL)isEmpty
{
    return (_startPos && _endPos);
}

@end
