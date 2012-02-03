//
//  Branch.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchNode.h"

@implementation BranchNode

@synthesize rootTreeSHA;

-(void) setValuesFromDictionary:(NSDictionary *)valueMap
{
    if ([valueMap objectForKey:@"name"]){
        self.name = [valueMap objectForKey:@"name"];
    }
    if ([valueMap objectForKey:@"commit"]){
        NSDictionary* commitHash = [valueMap objectForKey:@"commit"];
        
        if ([commitHash objectForKey:@"sha"]){
            self.commit = [commitHash objectForKey:@"sha"];
        }
    }
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/branches/%@.json", self.repoName, self.commit];
}

-(NSString *)type
{
    return NODE_TYPE_BRANCH;
}

@end
