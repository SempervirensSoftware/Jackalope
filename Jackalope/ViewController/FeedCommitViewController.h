//
//  FeedCommitViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commit.h"

@interface FeedCommitViewController : UITableViewController
{
    BOOL        _isLoading;
    BOOL        _isError;
    
    Commit*     _commit;
}

-(id) initWithCommit:(Commit*)commit;

@end
