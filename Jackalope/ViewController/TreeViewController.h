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

@interface TreeViewController : UITableViewController

@property (strong, nonatomic) CodeViewController *detailViewController;
@property (strong, nonatomic) TreeNode *tree;

@end
