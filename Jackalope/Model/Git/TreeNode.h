//
//  Tree.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNodeProvider.h"
#import "BranchNode.h"

@interface TreeNode : GitNode

@property (retain, nonatomic)   id<GitNodeProvider> nodeProvider;
@property (retain, nonatomic)   BranchNode*         parentBranch;

@end
