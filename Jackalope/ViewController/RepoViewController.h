//
//  RepoController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeViewController.h"

@interface RepoViewController : NSObject
{
    BOOL isRootTree;
    
    UINavigationController *_navController;
    
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSMutableDictionary *_treeHash;    

}

+ (RepoViewController *) getInstance;

@property (retain, readonly) UINavigationController* navController;
@property (retain) CodeViewController* codeViewController;

@property (retain) NSString* repoName;
@property (retain) NSString* repoRootSHA;

- (void) showBlobInCodeView:(TreeNode *) node;
- (void) showTreeInNav:(TreeNode *) node;
- (TreeNode *) getTreeNodeWithSHA:(NSString *) sha;

@end
