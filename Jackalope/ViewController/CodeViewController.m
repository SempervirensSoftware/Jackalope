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
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setActiveBlob:(TreeNode *)newBlob
{
    if (! _detailDescriptionLabel.hidden){
        _detailDescriptionLabel.hidden = true;
    }
        
    if (_activeBlob != newBlob) {
        _activeBlob = newBlob;
        self.title = newBlob.name;
        
        // Update the view.
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/files/%@", 
                                           [RepoViewController getInstance].repoName, 
                                           _activeBlob.sha]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        // Load the request into the web view
        [_codeView loadRequest:req];

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
    NSString *blobContent = [_codeView stringByEvaluatingJavaScriptFromString:@"getCodeContent();"];
    
    NSLog(@"blob:%@",blobContent);
    
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
