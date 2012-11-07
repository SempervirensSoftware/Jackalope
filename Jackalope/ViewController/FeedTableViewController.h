//
//  FeedViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commit.h"
#import "EGORefreshTableHeaderView.h"

@interface FeedTableViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isLoading;
    BOOL _isReloading;
    BOOL _isError;
    
    NSMutableArray*             _feed;
    UITableViewCell*            _notifyCell;

    EGORefreshTableHeaderView*  _refreshHeaderView;

    UINavigationController* _navController;
}

-(void) refreshFeed;
-(void) showCommit:(Commit*)commit;

@end
