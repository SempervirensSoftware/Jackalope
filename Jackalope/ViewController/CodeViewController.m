//
//  DetailViewController.m
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeViewController.h"
#import "RepoViewController.h"
#import "TreeNode.h"
#import "BlobCommit.h"
#import <QuartzCore/QuartzCore.h>

@interface CodeViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CodeViewController

@synthesize activeBlob = _activeBlob;
@synthesize codeView = _codeView;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setActiveBlob:(TreeNode *)newBlob
{        
    if (_activeBlob != newBlob) {
        _activeBlob = newBlob;
        self.title = newBlob.name;
        
        // Update the view.
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/files/%@.json", 
                                           [RepoViewController getInstance].repoName, 
                                           _activeBlob.sha]];

        _responseData = [[NSMutableData alloc] init];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        _connection = [[NSURLConnection alloc] initWithRequest:req
                                                      delegate:self
                                              startImmediately:YES];        
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    CALayer *layer = _codeView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                            initWithTitle:@"Commit" style:UIBarButtonItemStyleDone
                            target:self
                            action:@selector(commitPressed)];
    
    [self.navigationItem setRightBarButtonItem:bbi];

}

-(void) commitPressed
{
    NSString *blobContent = _codeView.code.plainText;
    
    BlobCommit *commit = [[BlobCommit alloc] initWithBlob:_activeBlob];
    commit.blobContent = blobContent;
    commit.repoRootSHA = [RepoViewController getInstance].repoRootSHA;
    [commit send];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - URL Connection

// This method will be called several times as the data arrives
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the incoming chunk of data to the container we are keeping
    // The data always comes in the correct order
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // We are just checking to make sure we are getting the XML
    NSString *responseString = [[NSString alloc] initWithData:_responseData
                                                     encoding:NSUTF8StringEncoding];
    Code* code = [[Code alloc] initWithPath:_activeBlob.name AndContents:responseString];
    _codeView.code = code;
    
    // Release the connection and response data, we're done with it
    _connection = nil;
    _responseData = nil;
    
}

- (void)connection:(NSURLConnection *)conn
  didFailWithError:(NSError *)error
{
    // Release the connection and response data, we're done with it
    _connection = nil;
    _responseData = nil;
    
    // Grab the description of the error object passed to us
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [error localizedDescription]];
    
    // Create and show an alert view with this error displayed
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    
    [av show];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"", @"");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Repo Browser", @"Repo Browser");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
