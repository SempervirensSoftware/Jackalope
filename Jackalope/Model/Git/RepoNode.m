//
//  Repo.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepoNode.h"
#import "TreeNode.h"
#import "BlobNode.h"
#import "BranchNode.h"

@implementation RepoNode

@synthesize isPrivate, masterBranch;

-(void) setValuesFromDictionary:(NSDictionary *)valueMap
{
    if ([valueMap objectForKey:@"id"]){
        self.sha = [valueMap objectForKey:@"id"];
    }
    if ([valueMap objectForKey:@"name"]){
        self.name = [valueMap objectForKey:@"name"];
    }
    if ([valueMap objectForKey:@"private"]){
        self.isPrivate = [[valueMap objectForKey:@"private"] boolValue];
    }
    if ([valueMap objectForKey:@"master_branch"]){
        self.masterBranch = [valueMap objectForKey:@"master_branch"];
    }
}

-(void) setValuesFromApiResponse:(NSString *)jsonString
{
    SBJSON *jsonParser = [SBJSON new];
    NSArray *branches = (NSArray *) [jsonParser objectWithString:jsonString];

    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
    
    for (NSDictionary *branchHash in branches) { 
        BranchNode* newNode = [[BranchNode alloc] init];
        [newNode setValuesFromDictionary:branchHash];
        newNode.repoName = self.name;
        newNode.operationQueue = self.operationQueue;
        [tempChildren addObject:newNode];
    }
    
    self.children = tempChildren;
}

-(NSString*) updateURL
{
    return [NSString stringWithFormat:@"%@/repo/%@/branches.json",kServerRootURL,self.name];
}

-(NSString *)type
{
    return NODE_TYPE_REPO;
}

@end
