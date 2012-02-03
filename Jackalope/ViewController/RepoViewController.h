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

@interface RepoViewController : NSObject
{
    UINavigationController* _navController;    

    RootNode*               _rootNode;
    RepoNode*               _currentRepo;
}

+ (RepoViewController *) getInstance;

@property (retain, readonly) UINavigationController* navController;
@property (retain) CodeViewController* codeViewController;

- (void) showNodeInNav:(GitNode*) node;
- (void) showBlobInCodeView:(GitNode*) node;

@end
