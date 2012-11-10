//
//  PTTextRange.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTTextRange.h"
#import "PTTextPosition.h"

@interface PTTextRange ()
    @property (nonatomic, retain) UITextPosition* start;
    @property (nonatomic, retain) UITextPosition* end;
@end

@implementation PTTextRange

@synthesize range = _range;
@synthesize start = _start;
@synthesize end = _end;

// Class method to create an instance with a given range
+(PTTextRange*)rangeWithStartPosition:(PTTextPosition *)startPosition andEndPosition:(PTTextPosition *)endPosition
{
    PTTextRange *range = [[PTTextRange alloc] init];
    range.start = startPosition;
    range.end = endPosition;
    return range;
}

// UITextRange read-only property - returns YES if range is zero length
-(BOOL)isEmpty
{
    PTTextPosition *start = (PTTextPosition*)self.start;
    PTTextPosition *end = (PTTextPosition*)self.end;
    return [start isEqualToPosition:end];
}

@end
