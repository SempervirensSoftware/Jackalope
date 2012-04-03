//
//  Branch.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"

@interface BranchNode : GitNode
{    
    NSMutableDictionary*    _nodeHash;        
}

@property (nonatomic, retain) NSString*             repoOwner;
@property (nonatomic, retain) NSString*             repoName;
@property (nonatomic, retain) NSString*             headCommitSHA;
@property (nonatomic, retain) GitNode*              rootTree;

-(GitNode *) getTreeNodeWithPath:(NSString *) fullPath;
-(GitNode *) getBlobNodeWithPath:(NSString *) fullPath;

-(void) commitBlobNode:(GitNode*)blob;

@end
