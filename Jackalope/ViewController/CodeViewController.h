//
//  DetailViewController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface CodeViewController : UIViewController <UISplitViewControllerDelegate>
{
    
    // http handlers
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSMutableDictionary *_treeHash;  
}

@property (strong, nonatomic) TreeNode *activeBlob;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIWebView *codeView;

@end
