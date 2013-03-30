//
//  SettingsViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 2/26/13.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (retain, nonatomic) UIButton* deleteButton;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect viewFrame = self.view.frame;

    CGRect buttonFrame = self.logoutBtn.frame;
    CGFloat logoutY = (viewFrame.origin.y + viewFrame.size.height - buttonFrame.size.height - 20);
    self.logoutBtn.frame = CGRectMake(buttonFrame.origin.x, logoutY, buttonFrame.size.width, buttonFrame.size.height);
    
    buttonFrame = self.feedbackBtn.frame;
    self.feedbackBtn.frame = CGRectMake(buttonFrame.origin.x, (self.logoutBtn.frame.origin.y - 10 - buttonFrame.size.height), buttonFrame.size.width, buttonFrame.size.height);
    
}
- (IBAction)sendFeedback:(id)sender{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller=[[MFMailComposeViewController alloc] init];
        
        controller.mailComposeDelegate = self;
        
        NSDictionary *appInfo=[[NSBundle mainBundle] infoDictionary];
        
        NSString *buildFull = [appInfo objectForKey:@"CFBundleVersion"];
        NSString *buildShort = [appInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *build = nil;
        if (buildFull) {
            build=[NSString stringWithFormat:@"%@ (%@)", buildShort, buildFull];
        } else {
            build=[NSString stringWithFormat:@"%@", buildShort];
        }
        
        NSString *subject=@"Jackalope Feedback";
        
        UIDevice *device=[UIDevice currentDevice];
        NSArray* appProfile=@[
                             @[ @"App Version", build ],
                             @[ @"OS", [NSString stringWithFormat:@"%@ %@", [device systemName], [device systemVersion]]],
                             @[ @"Model", [device model]]
                            ];
        
        NSMutableString* description = [[NSMutableString alloc] init];
        for (int i=0; i<[appProfile count]; i++) {
            NSArray *attribute=[appProfile objectAtIndex:i];
            [description appendFormat:@"%@: %@\n", [attribute objectAtIndex:0], [attribute objectAtIndex:1]];
        }
        
        [controller setSubject:subject];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n\n---------------\nDebug Info\n---------------\n%@",description] isHTML:NO];
        [controller setToRecipients:@[@"feedback@jackalope.me"]];
        [self presentModalViewController:controller animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't send mail from this device!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)logout:(id)sender{
    [CurrentUser logout];
    [GlobalAppDelegate showLogin];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
