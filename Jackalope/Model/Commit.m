//
//  Commit.m
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Commit.h"

@implementation Commit

@synthesize authorName, authorEmail, sha, message;

- (id) initWithDictionary:(NSDictionary*)values
{
    self = [super init];
    
    if (self)
    {
        self.sha = [values objectForKey:@"sha"];
        self.message = [values objectForKey:@"message"];                
        self.authorName = [values objectForKey:@"authorName"];
        self.authorEmail = [values objectForKey:@"authorEmail"];
    }

    return self;
}

@end
