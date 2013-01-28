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

// Class method to create an instance with a given range
+(PTTextRange*)rangeWithStartPosition:(PTTextPosition *)startPosition andEndPosition:(PTTextPosition *)endPosition
{
    PTTextRange *range = [[PTTextRange alloc] init];
    range.startPosition = startPosition;
    range.endPosition = endPosition;
    return range;
}

-(UITextPosition*)start{
    return self.startPosition;
}
-(UITextPosition*)end{
    return self.endPosition;
}

// UITextRange read-only property - returns YES if range is zero length
-(BOOL)isEmpty
{
    PTTextPosition *start = (PTTextPosition*)self.start;
    PTTextPosition *end = (PTTextPosition*)self.end;
    return [start isEqualToPosition:end];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ - %@", self.start, self.end];
}

@end
