//
//  Branch.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNodeProvider.h"
#import "GitNode.h"

@interface BranchNode : GitNode

@property (nonatomic, retain) NSString*             repoName;
@property (nonatomic, retain) NSString*             headCommitSHA;
@property (nonatomic, retain) GitNode*              rootTree;
@property (retain, nonatomic) id<GitNodeProvider>   nodeProvider;

-(void) commitBlobNode:(GitNode*)blob;

@end
