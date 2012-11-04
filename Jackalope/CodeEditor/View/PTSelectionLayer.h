//
//  PTSelectionLayer.h
//  Jackalope
//
//  Created by Peter Terrill on 11/3/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface PTSelectionLayer : CALayer

@property (nonatomic) NSUInteger    numLines;
@property (nonatomic) CGFloat       lineHeight;
@property (nonatomic) CGFloat       xStartOffset;
@property (nonatomic) CGFloat       xEndOffset;

@end
