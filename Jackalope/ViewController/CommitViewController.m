//
//  CommitViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommitViewController

@synthesize blobNode = _blobNode;
@synthesize fileName, commitMessage;

- (void) updateViewWithBlobContents
{
    if (_blobNode)
    {
        fileName.text = _blobNode.fullPath;           
    }
}

- (void) setBlobNode:(BlobNode *)blobNode
{
    _blobNode = blobNode;
    [self updateViewWithBlobContents];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self updateViewWithBlobContents];
    
    
    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];
    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];

    [self.navigationItem setLeftBarButtonItem:cancelBtn];
    self.title = @"Commit";
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    CALayer* layer = commitMessage.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3];
    [layer setBorderWidth:1.f];
    
    [commitMessage becomeFirstResponder];
}

-(void) cancelPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) donePressed
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    [nc addObserver:self selector:@selector(BlobCommitSuccess:) 
               name:NODE_COMMIT_SUCCESS object:_blobNode];        
    
    [nc addObserver:self selector:@selector(BlobCommitFailed:) 
               name:NODE_COMMIT_FAILED object:_blobNode];

    _blobNode.commitMessage = commitMessage.text;
    [_blobNode commit];
}

-(void)BlobCommitSuccess:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];   
    [[[UIAlertView alloc] initWithTitle:@"Success!"
                                message:@"Your changes were successfully committed to GitHub" 
                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];   

    [self.navigationController popViewControllerAnimated:YES];
    [TestFlight passCheckpoint:@"CommitSuccess"];
}

-(void)BlobCommitFailed:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];   
    [[[UIAlertView alloc] initWithTitle:@"Commit Failed"
                                message:@"There was a problem committing your changes. Please try again." 
                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];    
    [TestFlight passCheckpoint:@"CommitFailed"];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
