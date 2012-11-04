//
//  PTTextPosition.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTLineOfCode.h"

@interface PTTextPosition : UITextPosition

@property (nonatomic) NSUInteger index;
@property (nonatomic, retain) PTLineOfCode* loc;

+ (PTTextPosition *)positionInLine:(PTLineOfCode*)loc WithIndex:(NSUInteger)index;

-(BOOL) isEqualToPosition:(PTTextPosition *)otherPosition;

@end
