//
//  Event.m
//  Jackalope
//
//  Created by Peter Terrill on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize eventId, type, repoOwner, repoName, actorLogin, created_at;

- (id) initWithDictionary:(NSDictionary*)values
{
    self = [super init];
    
    if (self)
    {
        self.eventId = [values objectForKey:@"id"];
        self.type = [values objectForKey:@"type"];
        self.repoOwner = [values objectForKey:@"repoOwner"];
        self.repoName = [values objectForKey:@"repoName"];
        self.actorLogin = [values objectForKey:@"actorLogin"];
        self.created_at = [values objectForKey:@"created_at"];
    }
    
    return self;
}

@end
