//
//  DetailViewController.m
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeViewController.h"
#import "RepoViewController.h"
#import "CommitViewController.h"
#import "TreeNode.h"
#import "BlobNode.h"
#import <QuartzCore/QuartzCore.h>

@interface CodeViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CodeViewController

@synthesize codeView = _codeView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize loadingLabel, loadingActivityIndicator;

#pragma mark - Managing the detail item

-(void) showBlobNode:(BlobNode *)blob;
{        
    _blobNode = blob;
    self.title = blob.name;
    _codeView.code = [blob createCode];

    self.loadingLabel.hidden = YES;
    self.loadingActivityIndicator.hidden = YES;
    self.codeView.hidden = NO;
    [self.loadingActivityIndicator stopAnimating];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

-(void) showLoadingWithTitle:(NSString *)titleString 
{
    self.title = titleString;
    
    self.codeView.hidden = YES;
    self.loadingLabel.hidden = NO;
    self.loadingActivityIndicator.hidden = NO;
    [self.loadingActivityIndicator startAnimating];
}
-(void) showErrorWithTitle:(NSString *)titleString andMessage:(NSString *) message {
    self.title = titleString;
    self.codeView.hidden = YES;
    self.loadingLabel.hidden = YES;
    self.loadingActivityIndicator.hidden = YES;
    [self.loadingActivityIndicator stopAnimating];
}

- (void)configureView
{
    CALayer *layer = _codeView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3];
    
    _commitBtn = [[UIBarButtonItem alloc]
                            initWithTitle:@"Commit" style:UIBarButtonItemStyleDone
                            target:self
                            action:@selector(commitPressed)];
    //_commitBtn.enabled = NO;

    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_activityView sizeToFit];
    [_activityView setBackgroundColor:[UIColor blueColor]];
    [_activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin 
                                       | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    
    _activityBtn = [[UIBarButtonItem alloc] initWithCustomView:_activityView];
    
    [self.navigationItem setRightBarButtonItem:_commitBtn];
}

-(void) commitPressed
{    
    CommitViewController* commitController; 
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {            
        commitController = [[CommitViewController alloc] initWithNibName:@"CommitView_iPhone" bundle:nil];   
    }
    else
    {
        commitController = [[CommitViewController alloc] initWithNibName:@"CommitView_iPad" bundle:nil];   
    }

     _blobNode.fileContent = _codeView.code.plainText;
    commitController.blobNode = _blobNode;
    [self.navigationController pushViewController:commitController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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
