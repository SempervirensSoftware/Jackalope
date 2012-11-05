//
//  PTSelectionLayer.h
//  Jackalope
//
//  Created by Peter Terrill on 11/3/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface PTSelectionLayer : CALayer

@property (nonatomic) CGRect    startRect;
@property (nonatomic) CGRect    endRect;

@end
