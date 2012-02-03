//
//  MasterViewController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@class CodeViewController;

@interface GitNodeViewController : UITableViewController
{
    BOOL _isLoading;
    BOOL _isError;
}

@property (strong, nonatomic) CodeViewController *detailViewController;
@property (strong, nonatomic) GitNode *node;

-(void)NodeUpdateSuccess:(NSNotification *)note;
-(void)NodeUpdateFailed:(NSNotification *)note;

@end
