//
//  RootNode.m
//  Jackalope
//
//  Created by Peter Terrill on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootNode.h"
#import "RepoNode.h"

@implementation RootNode

- (id) init
{
    self = [super init];
    if (self)
    {
        self.operationQueue = [NSOperationQueue mainQueue];
        self.name = @"Repositories";
    }
    
    return  self;
}

- (void) setValuesFromRefreshResponse:(id)responseObject{
    if (![responseObject isKindOfClass:[NSArray class]])
        {  return; }
    
    NSArray* repos = (NSArray*) responseObject;
    NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
    
    for (NSDictionary *repoHash in repos) { 
        RepoNode* newNode = [[RepoNode alloc] init];
        newNode.operationQueue = self.operationQueue;
        [newNode setValuesFromDictionary:repoHash];        
        [tempChildren addObject:newNode];
    }

    self.children = tempChildren;
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"%@/repo.json", kServerRootURL];
}

-(NSString *)type
{
    return NODE_TYPE_ROOT;
}

@end
