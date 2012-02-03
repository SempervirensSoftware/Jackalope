//
//  Tree.m
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TreeNode.h"
#import "SBJSON.h"

@implementation TreeNode

@synthesize name, fullPath, sha, type, parentSha, repo, commit, children;

- (id) init
{
    self = [super init];
    
    if (self){
        children = [[NSArray alloc] init];
        fullPath = @"";
    }
    
    return self;
}
 
- (void) setValuesFromDictionary:(NSDictionary *) valueMap 
{
    if ([valueMap objectForKey:@"path"]){
        self.name = [valueMap objectForKey:@"path"];
    }
    if ([valueMap objectForKey:@"commit"])
    {
        self.commit = [valueMap objectForKey:@"commit"];
    }
}

- (void) setValuesFromApiResponse:(NSString *) jsonString{

    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *treeHash = (NSDictionary *) [jsonParser objectWithString:jsonString];
    
    [self setValuesFromDictionary:treeHash];
    
    NSArray *childrenHashes = (NSArray *) [treeHash objectForKey:@"tree"];
    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
    
    for (NSDictionary *childHash in childrenHashes) { 
        NSString* childType = [childHash objectForKey:@"type"];

        GitNode* child;
        
        if (childType == NODE_TYPE_TREE)
        {
            child = [self.repo getTreeNodeWithSHA:[childHash objectForKey:@"sha"]];
        }
        else
        {
            child = [self.repo getBlobNodeWithSHA:[childHash objectForKey:@"sha"]];
        }
        
        // load all the details we can from the response object
        [child setValuesFromDictionary:childHash];
        
        // add some local context
        child.parentSha = self.sha;
        child.commit = self.commit;
        
        if (self.fullPath.length > 0){
            child.fullPath = [NSString stringWithFormat:@"%@/%@",self.fullPath, child.name];
        }
        else{
            child.fullPath = child.name;
        }
        
        //finally add the new child to the list
        [tempChildren addObject:child];
    }
    
    children = [tempChildren sortedArrayUsingSelector:@selector(compare:)];
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree/%@.json", self.repo.name, self.sha];
}

-(NSString *)type
{
    return NODE_TYPE_REPO;
}


- (NSComparisonResult)compare:(TreeNode *)otherObject {
    if ([self.type isEqualToString:otherObject.type])
    {
        return [self.name compare:otherObject.name];
    }
    else if ([self.type isEqualToString:NODE_TYPE_TREE])
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedDescending;
    }
}

@end
