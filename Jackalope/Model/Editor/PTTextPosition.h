//
//  PTTextPosition.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineOfCode.h"

@interface PTTextPosition : UITextPosition

@property (nonatomic) NSUInteger index;
@property (nonatomic, retain) LineOfCode* loc;

+ (PTTextPosition *)positionInLine:(LineOfCode*)loc WithIndex:(NSUInteger)index;

@end
