//
//  FeedCommitSectionFooter.m
//  Jackalope
//
//  Created by Peter Terrill on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitSectionFooter.h"

CGFloat const _strokeThickness = 1.f;
CGFloat const _strokeXPadding  = 5.f;
CGFloat const _strokeYPadding  = 0.f;

@implementation FeedCommitSectionFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, _strokeThickness);
    
    CGContextMoveToPoint(context, _strokeXPadding, _strokeYPadding); //start at this point
    CGContextAddLineToPoint(context, (self.frame.size.width - (2*_strokeXPadding)), _strokeYPadding); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}


@end
