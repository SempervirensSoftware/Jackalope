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

#define HEADER_FONT_SIZE        18
#define HEADER_MIN_FONT_SIZE    18
#define DETAIL_FONT_SIZE        15
#define DETAIL_MIN_FONT_SIZE    15    
#define SUB_FONT_SIZE           13
#define SUB_MIN_FONT_SIZE       13    


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _headerFont = [UIFont fontWithName:@"HelveticaNeue" size:HEADER_FONT_SIZE];
        _detailFont = [UIFont fontWithName:@"HelveticaNeue" size:DETAIL_FONT_SIZE];
        _subFont    = [UIFont fontWithName:@"HelveticaNeue" size:SUB_FONT_SIZE];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    #define HEADER_TOP              8  
    #define HEADER_VERT_PADDING     5
    #define HEADER_OFFSET           10    
    #define HEADER_WIDTH            250
    #define HEADER_HEIGHT           20    
    
    #define TIMESTAMP_OFFSET        260    
    #define TIMESTAMP_WIDTH         40    
    
    #define DETAIL_HEIGHT           25
    #define DETAIL_VERT_PADDING     0
    #define DETAIL_ICON_OFFSET      20
    #define DETAIL_TEXT_OFFSET      38
    #define DETAIL_TEXT_WIDTH       262
    
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsXMax = contentRect.origin.x + contentRect.size.width;
    
    CGFloat currentY = 0.0;
    CGPoint drawPoint;
    
    // Set the color for the main text items.
    [[UIColor blackColor] set];
        
    // draw the row header
    currentY += HEADER_TOP;
    drawPoint = CGPointMake(boundsX + HEADER_OFFSET, currentY);
    [_event.actorLogin drawAtPoint:drawPoint forWidth:HEADER_WIDTH withFont:_headerFont minFontSize:HEADER_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    drawPoint = CGPointMake((boundsXMax- _timeStrSize.width - HEADER_OFFSET), (currentY+(HEADER_FONT_SIZE-SUB_FONT_SIZE)));
    [_timeStr drawAtPoint:drawPoint forWidth:TIMESTAMP_WIDTH withFont:_subFont minFontSize:SUB_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    // draw the action description
    currentY += (HEADER_HEIGHT + HEADER_VERT_PADDING);
    
    drawPoint = CGPointMake(boundsX + (DETAIL_ICON_OFFSET-3), currentY);
    [[UIImage imageNamed:@"glyphicons_358_file_import.png"] drawAtPoint:drawPoint];

    drawPoint = CGPointMake(boundsX + DETAIL_TEXT_OFFSET, currentY);
    [_repoStr drawAtPoint:drawPoint forWidth:DETAIL_TEXT_WIDTH withFont:_subFont minFontSize:SUB_MIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
    for (Commit* commit in _event.commits)
    {
        currentY += (DETAIL_HEIGHT + DETAIL_VERT_PADDING);

        drawPoint = CGPointMake(boundsX + DETAIL_ICON_OFFSET, (currentY+5));
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
        _timeStr = [event timeSinceNow];
        _timeStrSize = [_timeStr sizeWithFont:_detailFont];
        
        [self setNeedsDisplay];
    }
}

- (EventPush *) event
{
    return _event;
}


@end
