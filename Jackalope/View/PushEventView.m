//
//  PushEventView.m
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushEventView.h"
#import "Commit.h"

@implementation PushEventView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _headerFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        _detailFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    #define HEADER_TOP              8  
    #define HEADER_VERT_PADDING     3
    #define HEADER_OFFSET           10    
    #define HEADER_WIDTH            290
    #define HEADER_HEIGHT           20    
    #define HEADER_FONT_SIZE        15
    #define HEADER_MIN_FONT_SIZE    16
    
    #define DETAIL_HEIGHT           20
    #define DETAIL_VERT_PADDING     1
    #define DETAIL_ICON_OFFSET      20
    #define DETAIL_TEXT_OFFSET      38
    #define DETAIL_TEXT_WIDTH       262
    #define DETAIL_FONT_SIZE        12
    #define DETAIL_MIN_FONT_SIZE    12    
    
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    
    CGFloat currentY = 0.0;
    CGPoint drawPoint;
    
    // Set the color for the main text items.
    [[UIColor blackColor] set];
        
    // draw the row header
    currentY += HEADER_TOP;
    drawPoint = CGPointMake(boundsX + HEADER_OFFSET, currentY);
    [_event.actorLogin drawAtPoint:drawPoint forWidth:HEADER_WIDTH withFont:_headerFont minFontSize:HEADER_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    // draw the action description
    currentY += (HEADER_HEIGHT + HEADER_VERT_PADDING);

    drawPoint = CGPointMake(boundsX + (DETAIL_ICON_OFFSET-3), currentY);
    [[UIImage imageNamed:@"glyphicons_358_file_import.png"] drawAtPoint:drawPoint];

    drawPoint = CGPointMake(boundsX + DETAIL_TEXT_OFFSET, currentY);
    [_repoStr drawAtPoint:drawPoint forWidth:DETAIL_TEXT_WIDTH withFont:_detailFont minFontSize:DETAIL_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

    currentY += 5;
    
    for (Commit* commit in _event.commits)
    {
        currentY += (DETAIL_HEIGHT + DETAIL_VERT_PADDING);

        drawPoint = CGPointMake(boundsX + DETAIL_ICON_OFFSET, (currentY+3));
        [[UIImage imageNamed:@"checkin.png"] drawAtPoint:drawPoint];

        drawPoint = CGPointMake(boundsX + DETAIL_TEXT_OFFSET, currentY);
        [commit.message drawAtPoint:drawPoint forWidth:DETAIL_TEXT_WIDTH withFont:_detailFont minFontSize:DETAIL_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    }    
}

- (void) setEvent:(EventPush *)event
{
    if (event != _event)
    {
        _event = event;
        _repoStr = [NSString stringWithFormat:@"%@/%@",event.repoOwner,event.repoName];                

        [self setNeedsDisplay];
    }
}

- (EventPush *) event
{
    return _event;
}


@end
