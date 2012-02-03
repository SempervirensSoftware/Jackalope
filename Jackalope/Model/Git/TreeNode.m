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

@synthesize nodeProvider;
 
- (void) setValuesFromDictionary:(NSDictionary *) valueMap 
{
    if ([valueMap objectForKey:@"sha"]){
        self.sha = [valueMap objectForKey:@"sha"];
    }
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
        
        if ([childType isEqualToString:NODE_TYPE_TREE])
        {
            child = [self.nodeProvider getTreeNodeWithSHA:[childHash objectForKey:@"sha"]];
        }
        else if ([childType isEqualToString:NODE_TYPE_BLOB])
        {
            child = [self.nodeProvider getBlobNodeWithSHA:[childHash objectForKey:@"sha"]];
        }
        
        // load all the details we can from the response object
        [child setValuesFromDictionary:childHash];
        
        // add some local context
        child.parentSha = self.sha;
        child.commit = self.commit;
        
        if (self.fullPath && self.fullPath.length > 0){
            child.fullPath = [NSString stringWithFormat:@"%@/%@",self.fullPath, child.name];
        }
        else{
            child.fullPath = child.name;
        }
        
        NSLog(@"child:%@",childType);
        
        //finally add the new child to the list
        [tempChildren addObject:child];
    }
    
    self.children = [tempChildren sortedArrayUsingSelector:@selector(compare:)];
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree/%@.json", self.repoName, self.sha];
}

-(NSString *)type
{
    return NODE_TYPE_TREE;
}

@end
