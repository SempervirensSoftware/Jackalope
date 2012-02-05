//
//  GithubLoginViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GithubLoginViewController.h"
#import "NSURL+PTQueryParsing.h"
#import "AppUser.h"

@implementation GithubLoginViewController

@synthesize loginButton, activityIndicator, instructionLabel, successLabel, loadingLabel;

- (IBAction)login:(id)sender
{
    loginButton.enabled = NO;
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    
    _initialPageLoad = YES;
        
    NSURL *url = [NSURL URLWithString:@"http://vivid-stream-9812.heroku.com/oauth/github"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [_webView loadRequest:req];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    NSString* path = request.URL.path;
    NSRange range = [path rangeOfString:@"oauth/success"];

    NSLog(@"navigate@%@", request.URL.absoluteString);
    
    if (range.location != NSIntegerMax)
    {
        NSString* token = [request.URL queryValueForKey:@"token"];
        NSString* gitUserName = [request.URL queryValueForKey:@"gitUserName"]; 
        [AppUser currentUser].githubToken = token;
        [AppUser currentUser].githubUserName = gitUserName;

        NSLog(@"queryString: %@", request.URL.query);
        NSLog(@"loading user: %@(%@)", [AppUser currentUser].githubUserName, [AppUser currentUser].githubToken);
        
        instructionLabel.hidden = YES;
        loginButton.hidden = YES;
        successLabel.hidden = NO;
        loadingLabel.hidden = NO;

        if (!_initialPageLoad)
        {
            self.view = _mainView;
        }
        
        // shutdown the webview
        _webView.delegate = nil;
        _webView = nil;

        [GlobalAppDelegate userLoggedIn];
        
        return NO;
    }

    return YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    if (_initialPageLoad)
    {        
        _mainView = self.view; 
        self.view = webView;
        _initialPageLoad = false;
    }   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

@end
