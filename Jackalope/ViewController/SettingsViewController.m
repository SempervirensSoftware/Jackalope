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
}
- (IBAction)sendFeedback:(id)sender{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller=[[MFMailComposeViewController alloc] init];
        
        controller.mailComposeDelegate=self;
        
        NSDictionary *appInfo=[[NSBundle mainBundle] infoDictionary];
        
        NSString *buildFull = [appInfo objectForKey:@"CFBundleVersion"];
        NSString *buildShort = [appInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *build = nil;
        if (buildFull) {
            build=[NSString stringWithFormat:@"%@ (%@)", buildShort, buildFull];
        } else {
            build=[NSString stringWithFormat:@"%@", buildShort];
        }
        
        NSString *subject=[NSString stringWithFormat:@"Jackalope Feedback -  %@",build];
        
        UIDevice *device=[UIDevice currentDevice];
        NSArray* appProfile=@[
                             @[ @"App Version", build ],
                             @[ @"OS", [NSString stringWithFormat:@"%@ %@", [device systemName], [device systemVersion]]],
                             @[ @"Model", [device model]],
                             @[ @"Screen Scale", [NSString stringWithFormat:@"%.2f",[[UIScreen mainScreen] scale]]]
                            ];
        
        NSMutableString* description = [[NSMutableString alloc] init];
        for (int i=0; i<[appProfile count]; i++) {
            NSArray *attribute=[appProfile objectAtIndex:i];
            [description appendFormat:@"%@: %@\n", [attribute objectAtIndex:0], [attribute objectAtIndex:1]];
        }
        
        [controller setSubject:subject];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n\n---------------\nDebug Info\n---------------\n%@",description] isHTML:NO];
        [controller setToRecipients:@[@"peter@jackalope.me"]];
        [self presentModalViewController:controller animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't send mail from this device!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
