//
//  PushEventView.h
//  Jackalope
//
//  Created by Peter Terrill on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPush.h"

@interface PushEventView : UIView
{
    EventPush*  _event;
    UIFont*     _headerFont;
    UIFont*     _detailFont;
    
    NSString*   _repoStr;
}

@property (nonatomic, retain) EventPush* event;

@end
