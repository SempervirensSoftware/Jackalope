//
//  Repo.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BranchNode.h"
#import "GitNode.h"

@interface RepoNode : GitNode
{    
    NSMutableDictionary*    _nodeHash;        
    
    BranchNode*             _currentBranch;
    NSMutableArray*         _branchArray;
}

-(id) getTreeNodeWithSHA:(NSString *) sha;
-(id) getBlobNodeWithSHA:(NSString *) sha;

@end
