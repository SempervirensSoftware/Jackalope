//
//  RootNode.m
//  Jackalope
//
//  Created by Peter Terrill on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootNode.h"
#import "RepoNode.h"
#import "SBJSON.h"

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

- (void) setValuesFromApiResponse:(NSString *) jsonString{
    
    SBJSON *jsonParser = [SBJSON new];
    NSArray *repos = (NSArray *) [jsonParser objectWithString:jsonString];
    
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
    return @"http://vivid-stream-9812.heroku.com/repo.json";
}

-(NSString *)type
{
    return NODE_TYPE_ROOT;
}

@end
