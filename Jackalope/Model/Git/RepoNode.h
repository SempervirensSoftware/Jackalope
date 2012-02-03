//
//  Repo.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNodeProvider.h"
#import "BranchNode.h"

@interface RepoNode : GitNode <GitNodeProvider>
{    
    NSMutableDictionary*    _nodeHash;        
    BranchNode*             _currentBranch;
}

@property (nonatomic)           BOOL        isPrivate;
@property (retain, nonatomic)   NSString*   masterBranch;
@property (nonatomic, retain)   BranchNode*   currentBranch;

@end
