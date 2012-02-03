//
//  Tree.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepoNode.h"
#import "GitNode.h"

@interface TreeNode : GitNode

@property (retain, nonatomic) RepoNode*     repo;

@end
