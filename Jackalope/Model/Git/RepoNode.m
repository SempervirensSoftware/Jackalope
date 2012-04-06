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

@synthesize repoOwner;

-(void) setValuesFromDictionary:(NSDictionary *)valueMap
{
    if ([valueMap objectForKey:@"name"]){
        self.name = [valueMap objectForKey:@"name"];
    }
    if ([valueMap objectForKey:@"owner"]){
        self.repoOwner = [valueMap objectForKey:@"owner"];
    }
}

-(void) setValuesFromRefreshResponse:(id)responseObject
{
    if (![responseObject isKindOfClass:[NSArray class]])
    {  return; }
    
    NSArray* branches = (NSArray*) responseObject;
    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
    
    for (NSDictionary *branchHash in branches) { 
        BranchNode* newNode = [[BranchNode alloc] init];
        [newNode setValuesFromDictionary:branchHash];
        newNode.repoOwner = self.repoOwner;
        newNode.repoName = self.name;
        newNode.fullPath = [NSString stringWithFormat:@"%@/%@",self.name, newNode.name];
        newNode.operationQueue = self.operationQueue;
        [tempChildren addObject:newNode];
    }
    
    self.children = tempChildren;
}

-(NSString*) updateURL
{
    return [NSString stringWithFormat:@"%@/repo/%@/%@/branches.json",kServerRootURL,self.repoOwner,self.name];
}

-(NSString *)type
{
    return NODE_TYPE_REPO;
}

@end
