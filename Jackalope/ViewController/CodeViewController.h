//
//  DetailViewController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"
#import "PTCodeScrollView.h"

@interface CodeViewController : UIViewController <UISplitViewControllerDelegate>
{    
    // http handlers
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSMutableDictionary *_treeHash;  
    
    PTCodeScrollView* _codeView;
}

@property (strong, nonatomic) TreeNode *activeBlob;


@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet PTCodeScrollView *codeView;

@end
