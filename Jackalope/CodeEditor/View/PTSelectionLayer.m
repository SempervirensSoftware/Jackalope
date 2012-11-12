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
    UIColor *bgColor = [UIColor colorWithRed:172/255.f green:204/255.f blue:252/255.f alpha:1.f];
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    
    if (self.endRect.origin.y == self.startRect.origin.y){
        // only need to highlight a single line
        CGFloat topWidth = (self.endRect.origin.x - self.startRect.origin.x);
        CGRect topRect = CGRectMake(self.startRect.origin.x, 0, topWidth, self.startRect.size.height);
        CGContextFillRect(context, topRect);
    } else {
        // highlight the remainder of the top line
        CGFloat startY = (self.startRect.origin.y - self.frame.origin.y);
        CGFloat endY = (self.endRect.origin.y - self.frame.origin.y);
        
        CGFloat width = (self.frame.origin.x + self.frame.size.width - self.startRect.origin.x);
        CGRect topRect = CGRectMake(self.startRect.origin.x, 0, width, self.startRect.size.height);
        CGContextFillRect(context, topRect);

        // optionally highlight fully selected lines
        CGFloat bottomOfTopLine = (startY + self.startRect.size.height);
        CGFloat middleHeight = (endY - bottomOfTopLine);
        if (middleHeight > 0){
            CGRect middleRect = CGRectMake(self.frame.origin.x, bottomOfTopLine, self.frame.size.width, middleHeight);
            CGContextFillRect(context, middleRect);
        }

        // highlight the bottom line up to the end point
        CGFloat bottomWidth = (self.endRect.origin.x - self.frame.origin.x);
        CGRect bottomRect = CGRectMake(self.frame.origin.x, endY, bottomWidth, self.endRect.size.height);
        CGContextFillRect(context, bottomRect);
    }
}


@end
