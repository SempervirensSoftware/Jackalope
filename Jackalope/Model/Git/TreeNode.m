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

@synthesize name, fullPath, sha, type, parentSha, repoName, commit, children;

- (id) init
{
    self = [super init];
    
    if (self){
        children = [[NSArray alloc] init];
        fullPath = @"";
    }
    
    return self;
}
 
- (id) parseDictionary:(NSDictionary *) dictionary{

    if ([dictionary objectForKey:@"path"]){
        self.name = [dictionary objectForKey:@"path"];
    }
    if ([dictionary objectForKey:@"sha"])
    {
        self.sha = [dictionary objectForKey:@"sha"];
    }
    if ([dictionary objectForKey:@"type"]){
        self.type = [dictionary objectForKey:@"type"];
    }
    if ([dictionary objectForKey:@"commit"])
    {
        self.commit = [dictionary objectForKey:@"commit"];
    }
    
    return self;
}

- (id) parseTreeApiResponse:(NSString *) jsonString{

    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *treeHash = (NSDictionary *) [jsonParser objectWithString:jsonString];
    
    [self parseDictionary:treeHash];
    
    NSArray *childrenHashes = (NSArray *) [treeHash objectForKey:@"tree"];
    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
    
    for (NSDictionary *childHash in childrenHashes) { 
        TreeNode *child = [[TreeNode alloc] init];
        
        // get the details from the response object
        child = [child parseDictionary:childHash];
        
        // add some local context
        child.parentSha = self.sha;
        child.commit = self.commit;
        child.repoName = self.repoName;
        
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

    return self;
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


NSString *const NODE_TYPE_BLOB = @"blob";
NSString *const NODE_TYPE_TREE = @"tree";
NSString *const NODE_TYPE_REPOS = @"repos";
NSString *const NODE_TYPE_BRANCHES = @"branch";

@end
