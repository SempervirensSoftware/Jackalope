//
//  GithubLoginViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GithubLoginViewController.h"
#import "NSURL+PTQueryParsing.h"

@implementation GithubLoginViewController

@synthesize loginButton, activityIndicator, instructionLabel, successLabel, loadingLabel;

- (IBAction)login:(id)sender
{
    loginButton.enabled = NO;
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    
    _initialPageLoad = YES;
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/github", kServerRootURL]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieStore cookies]) {
        if ([cookie.domain rangeOfString:@"github.com"].location != NSNotFound)
        {
            [cookieStore deleteCookie:cookie];
        }        
    }
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [_webView loadRequest:req];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* path = request.URL.path;
    NSRange range = [path rangeOfString:@"oauth/success"];
    
    if (range.location != NSIntegerMax)
    {
        NSString* token = [request.URL queryValueForKey:@"token"];
        NSString* gitUserName = [request.URL queryValueForKey:@"gitUserName"]; 
        NSString* email = [request.URL queryValueForKey:@"email"]; 
        [CurrentUser loginWithToken:token email:email andUserName:gitUserName];

        NSLog(@"loginUser: %@(%@)", CurrentUser.githubUserName, CurrentUser.githubToken);
        [TestFlight passCheckpoint:@"LoginSuccess"];
        
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
    activityIndicator.hidden = YES;
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
