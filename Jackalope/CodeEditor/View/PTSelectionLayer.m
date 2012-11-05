//
//  PTSelectionLayer.m
//  Jackalope
//
//  Created by Peter Terrill on 11/3/12.
//
//

#import "PTSelectionLayer.h"

@implementation PTSelectionLayer

-(void) drawInContext:(CGContextRef)context{
    CGColorRef bgColor = [UIColor colorWithRed:172/255.f green:204/255.f blue:252/255.f alpha:1.f].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    
    if (self.endRect.origin.y > (self.startRect.origin.y + self.startRect.size.height)){
        CGFloat width = (self.frame.origin.x + self.frame.size.width - self.startRect.origin.x);
        CGRect topRect = CGRectMake(self.startRect.origin.x, 0, width, self.startRect.size.height);
        CGContextFillRect(context, topRect);
    } else {
        CGFloat width = (self.endRect.origin.x - self.startRect.origin.x);
        CGRect topRect = CGRectMake(self.startRect.origin.x,0,width,self.startRect.size.height);
        CGContextFillRect(context, topRect);
    }
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGColorRef bgColor = [UIColor colorWithRed:0.f green:0.f blue:1.f alpha:1.f].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);    
}


@end
