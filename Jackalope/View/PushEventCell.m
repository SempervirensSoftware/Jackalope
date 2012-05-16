//
//  EventCell.m
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushEventCell.h"

@implementation PushEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect viewFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width,
                                     self.contentView.bounds.size.height);
        _eventView = [[PushEventView alloc] initWithFrame:viewFrame];
        _eventView.contentMode = UIViewContentModeTopLeft;
        
        self.contentMode = UIViewContentModeTopLeft;        
        [self.contentView addSubview:_eventView];
    }
    return self;
}

+ (CGFloat) heightForEvent:(EventPush*)event
{
    #define STANDARD_HEIGHT     80
    #define INCREMENTAL_HEIGHT  20
    
    if (!event.commits || event.commits.count < 2)
    {
        return STANDARD_HEIGHT;
    }
    else {
        int extraRows = (event.commits.count - 1);
        if (extraRows > 3)
        {
            extraRows = 3;
        }
        
        return (STANDARD_HEIGHT + (INCREMENTAL_HEIGHT * extraRows));
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
