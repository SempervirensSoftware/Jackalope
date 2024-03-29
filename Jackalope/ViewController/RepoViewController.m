//
//  RepoController.m
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RepoViewController.h"
#import "GitNodeViewController.h"
#import "SBJSON.h"
#import "TreeNode.h"
#import "BlobNode.h"

@interface RepoViewController ()
- (void) showBlob:(BlobNode *)blob;
- (void) showCodeView;
@end

static RepoViewController *_instance = nil;

@implementation RepoViewController

@synthesize codeViewController = _codeViewController;

+ (RepoViewController *) getInstance
{
    if (!_instance) {
        // Create the singleton
        _instance = [[super allocWithZone:NULL] init];
    }
    
    return _instance;
}
// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)init {
    if (_instance) {
        // Return the existing instance
        return _instance;
    }
    
    // create a new instance
    self = [super init];

    if (self) {             
        _rootNode = [[RootNode alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserLoggedIn:) name:APPUSER_LOGIN object:nil];    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserLoggedOut:) name:APPUSER_LOGOUT object:nil];    
    }           
    
    return self;
}


-(UIViewController *) navController{
    if (_navController == nil){
        GitNodeViewController* rootViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {            
            rootViewController = [[GitNodeViewController alloc] initWithNibName:@"TreeView_iPhone" bundle:nil];
        }
        else
        {
            rootViewController = [[GitNodeViewController alloc] initWithNibName:@"TreeView_iPad" bundle:nil];   
        }
                
        rootViewController.title = @"Repo Browser";
        _navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        _navController.tabBarItem = [[UITabBarItem alloc]
                                         initWithTitle:@"Repos"
                                         image:[UIImage imageNamed:@"33-cabinet.png"] 
                                         tag:APP_TAB_REPOS]; 
    }    
    
    return _navController;
}

- (void) showRootNode
{
    GitNodeViewController* rootController = [_navController.childViewControllers objectAtIndex:0];
    rootController.node = _rootNode;
    [_navController popToRootViewControllerAnimated:YES];
}

- (void) showNode:(GitNode *)node withParent:(GitNode *)parentNode
{        
    if ([node.type isEqualToString:NODE_TYPE_BLOB])
    {
        if (_codeViewController.blobNode == node){
            [self showCodeView];
        }
        else if (_codeViewController.unsavedChanges){
            _pendingBlob = (BlobNode*)node;
            [[[UIAlertView alloc] initWithTitle:@"Unsaved Changes"
                                        message:[NSString stringWithFormat:@"Would you like to discard your changes to %@?", 
                                                 _codeViewController.blobNode.name] 
                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Discard", nil] show];   
            
        }
        else
        {        
            [self showBlob:(BlobNode*)node];
        }
    }
    else if (node)
    {
        GitNodeViewController* newTreeViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {            
            newTreeViewController = [[GitNodeViewController alloc] initWithNibName:@"TreeView_iPhone" bundle:nil];
        }
        else
        {
            newTreeViewController = [[GitNodeViewController alloc] initWithNibName:@"TreeView_iPad" bundle:nil];   
        }
        
        newTreeViewController.node = node;
        
        [self.navController pushViewController:newTreeViewController animated:YES];
    }
}
    
-(void) showBlob:(BlobNode *)blob
{
    [_codeViewController showLoadingWithTitle:blob.name];    
    [self showCodeView];
        
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];    
    [nc addObserver:self
           selector:@selector(BlobUpdateSuccess:)
               name:NODE_UPDATE_SUCCESS
             object:blob];    
    
    [nc addObserver:self
           selector:@selector(BlobUpdateFailed:)
               name:NODE_UPDATE_FAILED
             object:blob];

    
    [blob refresh];    
}

-(void) showSampleCode {
    [self showCodeView];
    [_codeViewController showSampleCode];
}


-(void) showCodeView{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.navController pushViewController:_codeViewController animated:YES];
    }
}

-(void) UserLoggedIn:(NSNotification*) note
{
    _rootNode = [[RootNode alloc] init]; 
    [self showRootNode];
}

-(void) UserLoggedOut:(NSNotification*) note
{
    _rootNode = nil;
}


-(void) BlobUpdateSuccess:(NSNotification*) note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BlobNode* blob = (BlobNode *) note.object;    
    _codeViewController.blobNode = blob;
    NSLog(@"openBlob:%@",blob.fullPath);
}
-(void) BlobUpdateFailed:(NSNotification*) note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BlobNode* blob = (BlobNode *) note.object;    
    [_codeViewController showErrorWithTitle:blob.name andMessage:@"Error loading file"];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self showBlob:_pendingBlob];        
    }
    else 
    {
        [self showCodeView];
    }
    _pendingBlob = nil;
}

@end
