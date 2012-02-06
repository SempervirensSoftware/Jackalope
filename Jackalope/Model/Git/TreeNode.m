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

@synthesize parentBranch;
 
- (void) setValuesFromDictionary:(NSDictionary *) valueMap 
{
    if ([valueMap objectForKey:@"sha"]){
        self.sha = [valueMap objectForKey:@"sha"];
    }
    if ([valueMap objectForKey:@"path"]){
        self.name = [valueMap objectForKey:@"path"];
    }
}

- (void) setValuesFromApiResponse:(NSString *) jsonString{

    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *treeHash = (NSDictionary *) [jsonParser objectWithString:jsonString];
    
    [self setValuesFromDictionary:treeHash];
    
    NSArray *childrenHashes = (NSArray *) [treeHash objectForKey:@"tree"];
    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];    

    NSString* pathPrefix = @"";
    if (self.fullPath && self.fullPath.length > 0) { pathPrefix = [NSString stringWithFormat:@"%@/",self.fullPath]; }
    
    for (NSDictionary *childHash in childrenHashes) { 
        NSString* childType = [childHash objectForKey:@"type"];
        NSString* childName = [childHash objectForKey:@"path"];        
        NSString* childFullPath = [NSString stringWithFormat:@"%@%@",pathPrefix,childName];        
        TreeNode* child;
        
        if ([childType isEqualToString:NODE_TYPE_TREE])
        {
            child = (TreeNode*)[self.parentBranch getTreeNodeWithPath:childFullPath];
        }
        else if ([childType isEqualToString:NODE_TYPE_BLOB])
        {
            child = (TreeNode*)[self.parentBranch getBlobNodeWithPath:childFullPath];
        }
        
        // load all the details we can from the response object
        [child setValuesFromDictionary:childHash];
        
        // local context
        child.fullPath = childFullPath;
        
        //finally add the new child to the list
        [tempChildren addObject:child];
    }
    
    self.children = [tempChildren sortedArrayUsingSelector:@selector(compare:)];
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree/%@.json", self.parentBranch.repoName, self.sha];
}

-(NSString *)type
{
    return NODE_TYPE_TREE;
}

@end
