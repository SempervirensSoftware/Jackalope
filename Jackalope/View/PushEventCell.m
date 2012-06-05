//
//  EventCell.m
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushEventCell.h"

@implementation PushEventCell

#define DETAIL_START_Y  60
#define DETAIL_HEIGHT   25

@synthesize feedController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect viewFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width,
                                     self.contentView.bounds.size.height);

        _eventView = [[PushEventView alloc] initWithFrame:viewFrame];
        _eventView.contentMode = UIViewContentModeTopLeft;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
        [_eventView setUserInteractionEnabled:YES];
        [_eventView addGestureRecognizer:tapGesture];
        
        self.contentMode = UIViewContentModeTopLeft;        
        [self.contentView addSubview:_eventView];
    }
    return self;
}

+ (CGFloat) heightForEvent:(EventPush*)event
{    
    if (!event.commits || event.commits.count == 0)
    {
        return DETAIL_START_Y;
    }
    else {
        NSInteger rows = event.commits.count;
        
        if (rows > 4)
        {
            rows = 4;
        }
        
        NSInteger height = (DETAIL_START_Y + (DETAIL_HEIGHT * rows));
        return height;
    }
}

- (void)cellTap:(UIGestureRecognizer*)sender
{
    Commit* commit = nil;
    
    CGPoint tapPoint = [sender locationInView:sender.view.superview];
    CGFloat tapY = tapPoint.y;

    tapY -= DETAIL_START_Y;
    if (tapY > 0)
    {
        NSInteger index = floor(tapY / DETAIL_HEIGHT);
        EventPush* event = _eventView.event;
        
        if (index >= 0 && index < event.commits.count){
            commit = [event.commits objectAtIndex:index];
        }
    }
    
    if (commit)
    {
        [self.feedController showCommit:commit];
    }
}

- (void) setEvent:(EventPush *)event
{
    _eventView.event = event;
    CGRect fr = _eventView.frame;
    _eventView.frame = CGRectMake(fr.origin.x, fr.origin.y, fr.size.width, [PushEventCell heightForEvent:event]);
}

- (EventPush*)event
{
    return _eventView.event;
}

@end
