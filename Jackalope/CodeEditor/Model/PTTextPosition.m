//
//  PTTextPosition.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTTextPosition.h"
#import "PTCodeLayer.h"
#import "PTLineOfCode.h"

@implementation PTTextPosition

+ (PTTextPosition *)positionInLayer:(PTCodeLayer*)layer InLine:(PTLineOfCode*)loc WithIndex:(NSUInteger)index{
    PTTextPosition *pos = [[PTTextPosition alloc] init];
    pos.layer = layer;
    pos.loc = loc;
    pos.index = index;
    
    return pos;
}

-(CGRect) createRect {
    return [self.layer createRectForPosition:self];
}

-(BOOL) isEqualToPosition:(PTTextPosition *)otherPosition{
    return ((self.layer == otherPosition.layer) && (self.loc == otherPosition.loc) && (self.index == otherPosition.index));
}

-(id) copy
{
    return [PTTextPosition positionInLayer:self.layer InLine:self.loc WithIndex:self.index];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"(%d, %d)", self.loc.lineNum, self.index];
}

@end
