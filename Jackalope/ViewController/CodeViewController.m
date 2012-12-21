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

@interface CodeViewController (){
    UIButton *_keyboardButton;
    UIButton *_searchButton;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end


@implementation CodeViewController

@synthesize codeView = _codeView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize unsavedChanges = _unsavedChanges;
@synthesize loadingLabel, loadingActivityIndicator;
@synthesize blobNode = _blobNode;

#pragma mark - Managing the detail item

- (void)configureView
{
    [_codeView addCodeViewDelegate:self];
    CALayer *layer = _codeView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3];    
    
    _commitBtn = [[UIBarButtonItem alloc]
                  initWithTitle:@"Commit" style:UIBarButtonItemStyleDone
                  target:self
                  action:@selector(commitPressed)];
    _commitBtn.enabled = NO;
    _unsavedChanges = false;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_activityView sizeToFit];
    [_activityView setBackgroundColor:[UIColor blueColor]];
    [_activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin 
                                        | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    
    _activityBtn = [[UIBarButtonItem alloc] initWithCustomView:_activityView];
    
    [self.navigationItem setRightBarButtonItem:_commitBtn];
}

-(void) dealloc
{
    [_codeView removeCodeViewDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setBlobNode:(BlobNode *)blob;
{        
    if (_blobNode != blob)
    {
        _blobNode = blob;
        self.title = blob.name;
        _codeView.code = [blob createCode];
        
        if (_unsavedChanges)
        {
            _unsavedChanges = false;
            _commitBtn.enabled = NO;
        }

        [self showCodeView];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [nc addObserver:self selector:@selector(BlobCommitSuccess:) 
                   name:NODE_COMMIT_SUCCESS object:_blobNode]; 
    }
}

-(void) showSampleCode
{
    _blobNode = nil;
    self.title = @"**Sample**";
    
    // load the samplefile    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tree_controller" ofType:@"rb"];
    NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    Code *code = [[Code alloc] init];
    code.plainText = text;
    code.fileName = @"tree_controller.rb";
    _codeView.code = code;
    
    [self showCodeView];
    
}

-(void) showLoadingWithTitle:(NSString *)titleString 
{
    self.title = titleString;
    
    [self.codeView hideKeyboard];
    self.codeView.hidden = YES;
    self.loadingLabel.hidden = NO;
    self.loadingActivityIndicator.hidden = NO;
    [self.loadingActivityIndicator startAnimating];
    
    if (_unsavedChanges)
    {
        _unsavedChanges = false;
        _commitBtn.enabled = NO;
    }
}
-(void) showErrorWithTitle:(NSString *)titleString andMessage:(NSString *) message {
    self.title = titleString;
    self.codeView.hidden = YES;
    self.loadingLabel.hidden = YES;
    self.loadingActivityIndicator.hidden = YES;
    [self.loadingActivityIndicator stopAnimating];
}

-(void) showCodeView {
    self.loadingLabel.hidden = YES;
    self.loadingActivityIndicator.hidden = YES;
    self.codeView.hidden = NO;
    [self.loadingActivityIndicator stopAnimating];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma Keyboard Events

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification *)notification
{
    if (!_keyboardButton){
        _keyboardButton = [[UIButton alloc] init];
        [_keyboardButton setImage:[UIImage imageNamed:@"glyphicons_268_keyboard_wireless"] forState:UIControlStateNormal];
        [_keyboardButton addTarget:self action:@selector(hideKeyboardPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardButton sizeToFit];
    }
    if (!_searchButton){
        _searchButton = [[UIButton alloc] init];
        [_searchButton setImage:[UIImage imageNamed:@"01-magnify.png"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_searchButton sizeToFit];
    }

    // find out where the keyboard is
    NSDictionary* info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    // show the keyboard button
    CGFloat hideButtonX = keyboardRect.origin.x + keyboardRect.size.width - (_keyboardButton.frame.size.width + 5);
    CGFloat hideButtonY =  keyboardRect.origin.y - self.codeView.frame.origin.y - _keyboardButton.frame.size.height - 5;
    CGRect hideButtonFrame = CGRectMake(hideButtonX, hideButtonY, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
    _keyboardButton.frame = hideButtonFrame;
    [self.view addSubview:_keyboardButton];
    
    // show the find button
    CGRect searchFrame = CGRectMake(hideButtonX-5-_searchButton.frame.size.width , hideButtonY, _searchButton.frame.size.width, _searchButton.frame.size.height);
    _searchButton.frame = searchFrame;
    [self.view addSubview:_searchButton];
}

-(void) searchButtonPressed:(id)sender {
    CGRect frame = _searchButton.frame;
    CGRect newFrame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        _searchButton.frame = newFrame;
    }];
}

-(void) keyboardWillHide:(NSNotification *)notification{
    [_keyboardButton removeFromSuperview];
    [_searchButton removeFromSuperview];
}

-(void) hideKeyboardPressed:(id)sender{
    [self.codeView hideKeyboard];
}

-(void) textDidChange:(id<UITextInput>)textInput
{
    if (! _unsavedChanges)
    {
        _unsavedChanges = YES;
        _commitBtn.enabled = YES;        
    }
}
-(void) textWillChange:(id<UITextInput>)textInput {}
-(void) selectionDidChange:(id<UITextInput>)textInput {}
-(void) selectionWillChange:(id<UITextInput>)textInput {}

# pragma mark Commits

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

-(void)BlobCommitSuccess:(NSNotification *)note
{
    _unsavedChanges = NO;
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
