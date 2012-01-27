//
//  RepoController.m
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RepoViewController.h"
#import "TreeViewController.h"
#import "SBJSON.h"
#import "TreeNode.h"

static RepoViewController *_instance = nil;

@implementation RepoViewController

@synthesize repoName = _repoName;
@synthesize codeViewController = _codeViewController;
@synthesize repoRootSHA = _repoRootSHA;

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

//    TODO  This is a good place to look for a local cache of repo's
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:@"FBAccessTokenKey"] 
//        && [defaults objectForKey:@"FBExpirationDateKey"]) {
//        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
//        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
//    } 
    
    // TODO stop hardcoding the repo!
    _repoName = @"TouchCodeRails";
    
    _responseData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@.json",_repoName]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    _connection = [[NSURLConnection alloc] initWithRequest:req
                                                  delegate:self
                                          startImmediately:YES];

    _treeHash = [[NSMutableDictionary alloc] init];
    isRootTree = true;
        
    return self;
}


-(UIViewController *) navController{
    if (_navController == nil){
        TreeViewController* masterViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {            
            masterViewController = [[TreeViewController alloc] initWithNibName:@"TreeView_iPhone" bundle:nil];
        }
        else
        {
            masterViewController = [[TreeViewController alloc] initWithNibName:@"TreeView_iPad" bundle:nil];   
        }
                
        [masterViewController setTitle:@"Repo Browser"];
        _navController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    }
    
    return _navController;
}

- (void) showBlobInCodeView:(TreeNode *) blob{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.navController pushViewController:_codeViewController animated:YES];
    }
    
    _codeViewController.activeBlob = blob;
}

- (void) showTreeInNav:(TreeNode *) node{    
    TreeNode *tempNode = [_treeHash objectForKey:node.sha];
    NSLog(@"getSHA:%@", node.sha);

    if (tempNode == nil)
    {
        _responseData = [[NSMutableData alloc] init];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree/%@.json", _repoName, node.sha]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        _connection = [[NSURLConnection alloc] initWithRequest:req
                                                      delegate:self
                                              startImmediately:YES];
        
        tempNode = node;
    }
    
    TreeViewController* newTreeViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {            
        newTreeViewController = [[TreeViewController alloc] initWithNibName:@"TreeView_iPhone" bundle:nil];
    }
    else
    {
        newTreeViewController = [[TreeViewController alloc] initWithNibName:@"TreeView_iPad" bundle:nil];   
    }
    newTreeViewController.tree = tempNode;
    
    [self.navController pushViewController:newTreeViewController animated:YES];
}


- (TreeNode *) getTreeNodeWithSHA:(NSString *) sha{
    return (TreeNode *)[_treeHash objectForKey:sha];
}



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
    
    TreeViewController *currentTreeView = (TreeViewController *) [_navController.childViewControllers lastObject];
        
    // REMOVE this is a remnant of hardcoding the repo
    currentTreeView.tree.repoName = _repoName;
    
    TreeNode *responseTree = (TreeNode *)[currentTreeView.tree parseTreeApiResponse:responseString];                          
    currentTreeView.tree = responseTree;
    
    if (isRootTree){
        isRootTree = false;
        _repoRootSHA = responseTree.sha;
    }
    
    //cache the result
    NSLog(@"setSHA:%@", responseTree.sha);
    [_treeHash setValue:responseTree forKey:responseTree.sha];
    
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



@end
