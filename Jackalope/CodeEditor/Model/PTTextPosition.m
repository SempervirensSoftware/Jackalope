//
//  PTTextPosition.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTTextPosition.h"

@implementation PTTextPosition

@synthesize index = _index;
@synthesize loc = _loc;

// Class method to create an instance with a given integer index
+ (PTTextPosition *)positionInLine:(PTLineOfCode *)loc WithIndex:(NSUInteger)index
{
    PTTextPosition *pos = [[PTTextPosition alloc] init];    
    pos.index = index;
    pos.loc = loc;
    
    return pos;
}

-(id) copy
{
    return [PTTextPosition positionInLine:_loc WithIndex:_index];
}

-(BOOL) isEqualToPosition:(PTTextPosition *)otherPosition{
    return ((self.loc == otherPosition.loc) && (self.index == otherPosition.index));
}

@end
