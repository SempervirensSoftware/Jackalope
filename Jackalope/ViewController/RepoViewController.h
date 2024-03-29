//
//  RepoController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeViewController.h"
#import "GitNode.h"
#import "RootNode.h"
#import "RepoNode.h"
#import "BlobNode.h"

@interface RepoViewController : NSObject <UIAlertViewDelegate>
{
    UINavigationController* _navController;    

    RootNode*               _rootNode;
    RepoNode*               _currentRepo;
    
    BlobNode*               _pendingBlob;
}

+ (RepoViewController *) getInstance;

@property (retain, readonly)    UINavigationController* navController;
@property (retain)              CodeViewController*     codeViewController;

- (void) showRootNode;
- (void) showNode:(GitNode*)node withParent:(GitNode*)parentNode;
- (void) showSampleCode;

@end
