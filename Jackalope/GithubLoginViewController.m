//
//  GithubLoginViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GithubLoginViewController.h"
#import "NSURL+PTQueryParsing.h"
#import "NSData+Base64.h"
#import "SBJSON.h"
#import <QuartzCore/QuartzCore.h>

@interface  GithubLoginViewController () <UITextFieldDelegate>
-(void) initLoginTable;
@end

@implementation GithubLoginViewController

@synthesize loginButton, activityIndicator, instructionLabel, statusLabel;

- (IBAction)login:(id)sender
{
    NSString* email = emailCell.textField.text;
    if (!email || email.length < 1)
    {
        statusLabel.text = @"*Email Required";
        statusLabel.hidden = NO;
        [emailCell setFocus];
        return;
    }
        
    NSString* password = passwordCell.textField.text;
    if (!password || password.length < 1)
    {
        statusLabel.text = @"*Password Required";
        statusLabel.hidden = NO;
        [passwordCell setFocus];
        return;
    }
    
    statusLabel.hidden = YES;
    loginButton.enabled = NO;
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    
    // Calculate Base64 Auth header
    NSString* authStr = [NSString stringWithFormat:@"%@:%@", email, password];
    NSData*   authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString* authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
    
    // Setup the POST body
    NSArray* scopes = [[NSArray alloc] initWithObjects:@"user", @"repo", nil];
    NSDictionary* map = [[NSDictionary alloc] initWithObjectsAndKeys:scopes, @"scopes", @"Jackalope", @"note", kServerRootURL, @"note_url", nil];
    SBJSON *jsonWriter = [SBJSON new];
    NSString *jsonString = [jsonWriter stringWithObject:map];
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/authorizations"];     
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
    [req setValue:authValue forHTTPHeaderField:@"Authorization"];
    [req setHTTPBody: [jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         [activityIndicator stopAnimating];
         activityIndicator.hidden = YES;
         
         if (error)
         {                                     
             if (error.code == -1012)
             {
                 statusLabel.text = @"Invalid login. Please try again.";
                  NSLog(@"Invalid Login");     
             }
             else {
                 statusLabel.text = @"Error while logging in. Please try again.";
                 NSLog(@"Unknown Login Error:%@", [error.userInfo description]);                 
             }
             
             loginButton.enabled = YES;
         }
         else
         {
             NSString* responseString = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
             SBJSON* jsonParser = [SBJSON new];
             NSDictionary* authHash = (NSDictionary *) [jsonParser objectWithString:responseString];
             NSString* token = [authHash objectForKey:@"token"];
             
             if (!token)
             {
                 statusLabel.text = @"Error while logging in. Please try again.";
                 loginButton.enabled = YES;
                 NSLog(@"Login response incomplete:%@", responseString);                                  
             }
             else 
             {
                 statusLabel.text = @"Login Success. Loading your data...";
                 [self registerWithJackalope:token];
             }
         }         
         
         statusLabel.hidden = NO;
     }];
}

-(void) registerWithJackalope:(NSString *)GithubToken
{
    NSString* urlString = [NSString stringWithFormat:@"%@/users/register.json?token=%@", kServerRootURL, GithubToken];
    NSURL *url = [NSURL URLWithString:urlString];     
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         if (error)
         {
             statusLabel.text = @"Error loading data. Please try again.";
             loginButton.enabled = YES;          
             NSLog(@"Registration Error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]);                 
             return;
         }
         else
         {
             NSString *responseString = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
             
             SBJSON* jsonParser = [SBJSON new];
             NSDictionary* registrationHash = (NSDictionary *) [jsonParser objectWithString:responseString];
             NSString* token = [registrationHash objectForKey:@"token"];
             NSString* email = [registrationHash objectForKey:@"email"];
             NSString* userName = [registrationHash objectForKey:@"gitUserName"];
             
             if (!token || !email || !userName){
                 statusLabel.text = @"Error loading user profile. Please try again.";
                 loginButton.enabled = YES;
                 return;
             }
             
             [CurrentUser loginWithToken:token email:email andUserName:userName];
             [GlobalAppDelegate userLoggedIn];
         }
     }];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    activityIndicator.hidden = YES;
    
    [self initLoginTable];   
}

-(void) initLoginTable
{
    // set default frame for iPhone view
    CGRect tableFrame = CGRectMake(5, 50, self.view.frame.size.width-10, 120);    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {        
        tableFrame.origin.y = 150;
        tableFrame.size.width = 300;
        tableFrame.origin.x = (self.view.frame.size.width - tableFrame.size.width)/2;
    }
    
    UITableView* table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.backgroundView = nil;
    table.scrollEnabled = NO;
    table.allowsSelection = NO;
    
    [self.view addSubview:table];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table Experiment
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        if (emailCell == nil)
        {
            emailCell = [[LoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"email"];
            emailCell.textField.delegate = self;
            [emailCell setFieldType:LOGIN_CELL_EMAIL];
            [emailCell setFocus];
        }
        return emailCell;
    }
    else if (indexPath.row == 1) {
        if (passwordCell == nil){
            passwordCell = [[LoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"password"];
            passwordCell.textField.delegate = self;
            [passwordCell setFieldType:LOGIN_CELL_PASSWORD];
        }
        return passwordCell;
    }

    return nil;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyDone){
        [self login:nil];
    } else {
        [passwordCell setFocus];
    }
    
    return YES;
}


@end
