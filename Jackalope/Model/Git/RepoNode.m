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

@implementation RepoNode

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

-(id) getTreeNodeWithSHA:(NSString *) sha
{
    TreeNode* node = [_nodeHash objectForKey:sha];

    if (!node)
    {
        node = [[TreeNode alloc] init];
        node.sha = sha;
        node.repo = self;
        [_nodeHash setObject:node forKey:sha];
    }
    
    return node;
}

-(id) getBlobNodeWithSHA:(NSString *) sha
{
    BlobNode* node = [_nodeHash objectForKey:sha];
    
    if (!node)
    {
        node = [[BlobNode alloc] init];
        node.sha = sha;
        [_nodeHash setObject:node forKey:sha];
    }
    
    return node;
}

-(NSString*) updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@.json",self.name];
}

-(NSString *)type
{
    return NODE_TYPE_REPO;
}

@end
