//
//  EventPush.m
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventPush.h"
#import "Commit.h"

@implementation EventPush

@synthesize ref, commits;

- (id) initWithDictionary:(NSDictionary*)values
{
    self = [super initWithDictionary:values];
    
    if (self)
    {
        self.ref = [values objectForKey:@"ref"];

        NSArray* commitHashes = (NSArray*)[values objectForKey:@"commits"];
        if (commitHashes && commitHashes.count > 0)
        {
            NSMutableArray* tempCommits = [[NSMutableArray alloc] initWithCapacity:commitHashes.count];
            Commit* tempCommit = nil;
            for (NSDictionary* commitHash in commitHashes)
            {
                tempCommit = [[Commit alloc] init];
                [tempCommit setValuesFromDictionary:commitHash];
                tempCommit.repoName = self.repoName;
                tempCommit.repoOwner = self.repoOwner;
                [tempCommits addObject:tempCommit];
            }        
            self.commits = tempCommits;
        }
    }
    
    return self;
}


@end
