//
//  EventCell.h
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPush.h"
#import "PushEventView.h"

@interface PushEventCell : UITableViewCell{
    PushEventView*  _eventView;
}

@property(nonatomic, retain) EventPush* event;

+ (CGFloat) heightForEvent:(EventPush*)event;

@end
