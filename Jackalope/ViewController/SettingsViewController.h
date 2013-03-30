//
//  SettingsViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 2/26/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet  UIButton*   feedbackBtn;
@property (nonatomic, retain) IBOutlet  UIButton*   logoutBtn;

- (IBAction)sendFeedback:(id)sender;
- (IBAction)logout:(id)sender;

@end
