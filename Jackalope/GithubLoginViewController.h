//
//  GithubLoginViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginTableViewCell.h"

@interface GithubLoginViewController : UIViewController <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL _initialPageLoad;
    UIView* _mainView;
    UIWebView* _webView;
    
    LoginTableViewCell* emailCell;
    LoginTableViewCell* passwordCell;
}

@property (nonatomic, retain) IBOutlet UILabel  *instructionLabel;
@property (nonatomic, retain) IBOutlet UILabel  *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)login:(id)sender;

@end
