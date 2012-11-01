//
//  FeedCommitInfo.h
//  Jackalope
//
//  Created by Peter Terrill on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commit.h"

@interface FeedCommitInfoCell : UITableViewCell
{
    UILabel* _userLabel;
    UILabel* _dateLabel;
    UILabel* _messageLabel;
    
    NSDateFormatter* _dateFormatter;
}

@property (nonatomic, assign)   Commit*   commit;

-(void)refresh;

@end
