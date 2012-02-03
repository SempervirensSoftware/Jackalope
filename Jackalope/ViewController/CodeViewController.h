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
    Code* _code;
}

@property (nonatomic, retain) IBOutlet PTCodeScrollView* codeView;

-(void) showCode:(Code *) code;
-(void) showLoadingWithTitle:(NSString *)titleString;
-(void) showErrorWithTitle:(NSString *)titleString andMessage:(NSString *) message;

@end
