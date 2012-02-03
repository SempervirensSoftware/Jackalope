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
#import "AppUser.h"

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
        rootViewController.node  = _rootNode;
        _navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    }    
    
    return _navController;
}

- (void) showNodeInNav:(GitNode *) node
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

- (void) showBlobInCodeView:(GitNode *) blobNode{

    if (blobNode.type != NODE_TYPE_BLOB)
    {
        return;
    }
    
    BlobNode* blob = (BlobNode*)blobNode;    
    [_codeViewController showLoadingWithTitle:blob.name];    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.navController pushViewController:_codeViewController animated:YES];
    }
        
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

    
    [blob refreshData];    
}


-(void) BlobUpdateSuccess:(NSNotification*) note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BlobNode* blob = (BlobNode *) note.object;    
    [_codeViewController showCode:[blob createCode]];
}
-(void) BlobUpdateFailed:(NSNotification*) note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BlobNode* blob = (BlobNode *) note.object;    
    [_codeViewController showErrorWithTitle:blob.name andMessage:@"Error loading file"];
}

@end
