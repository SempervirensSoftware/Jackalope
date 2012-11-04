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
    CGColorRef bgColor = [UIColor colorWithRed:0.f green:0.f blue:1.f alpha:1.f].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    
    if (self.numLines == 1){
        CGRect selectRect = CGRectMake(self.frame.origin.x + self.xStartOffset, self.frame.origin.y, self.frame.origin.x+ self.xEndOffset, self.lineHeight);
        CGContextFillRect(context, selectRect);
    } else if (self.numLines > 1){
        CGRect firstRect = CGRectMake(self.frame.origin.x + self.xStartOffset, self.frame.origin.y, self.frame.size.width, self.lineHeight);
        CGContextFillRect(context, firstRect);
        
        for (int i = 1; i < (numLines-1)
    }
}

@end
