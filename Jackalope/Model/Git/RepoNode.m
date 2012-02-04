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

-(void) commonInit
{
    _nodeHash = [[NSMutableDictionary alloc] init];
}

-(id) init
{
    self = [super init];
    if (self){
        [self commonInit];
    }
    return self;
}

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
        newNode.nodeProvider = self;
        [tempChildren addObject:newNode];
    }
    
    self.children = tempChildren;
}

-(GitNode *) getTreeNodeWithSHA:(NSString *) sha
{
    TreeNode* node = [_nodeHash objectForKey:sha];

    if (!node)
    {
        node = [[TreeNode alloc] init];
        node.sha = sha;
        node.nodeProvider = self;
        [_nodeHash setObject:node forKey:sha];
    }
    
    return node;
}

-(GitNode *) getBlobNodeWithSHA:(NSString *) sha
{
    BlobNode* node = [_nodeHash objectForKey:sha];
    
    if (!node)
    {
        node = [[BlobNode alloc] init];
        node.sha = sha;
        node.nodeProvider = self;
        [_nodeHash setObject:node forKey:sha];
    }
    
    return node;
}

-(NSString*) updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/branches.json",self.name];
}

-(NSString *)type
{
    return NODE_TYPE_REPO;
}

@end
