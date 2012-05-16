//
//  PushEventView.h
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPush.h"
#import "Commit.h"

@interface PushEventView : UIView
{
    EventPush*  _event;
    UIFont*     _headerFont;
    UIFont*     _detailFont;
    UIFont*     _subFont;
    
    NSString*   _repoStr;
    NSString*   _timeStr;
    CGSize      _timeStrSize;
}

@property (nonatomic, retain) EventPush* event;

@end
