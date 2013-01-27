//
//  PTTextPosition.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTLineOfCode.h"

@class PTCodeLayer;

@interface PTTextPosition : UITextPosition

@property (nonatomic) NSUInteger index;
@property (nonatomic, retain) PTLineOfCode* loc;
@property (nonatomic, retain) PTCodeLayer* layer;

+ (PTTextPosition *)positionInLayer:(PTCodeLayer*)layer InLine:(PTLineOfCode*)loc WithIndex:(NSUInteger)index;

-(CGRect) createRect;
-(BOOL) isEqualToPosition:(PTTextPosition *)otherPosition;

@end
