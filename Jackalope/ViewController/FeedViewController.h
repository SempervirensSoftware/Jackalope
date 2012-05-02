//
//  FeedViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewController : UITableViewController
{
    BOOL _isLoading;
    BOOL _isError;
    
    NSMutableArray*     _feed;
    UITableViewCell*    _notifyCell;
}

-(void) refreshFeed;

@end
