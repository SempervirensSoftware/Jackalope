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
        
        NSString* createdStr = [values objectForKey:@"created_at"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        self.created_at = [dateFormatter dateFromString:createdStr];
    }
    
    return self;
}

- (NSString*) timeSinceNow{
    NSTimeInterval delta = (-1 * [self.created_at timeIntervalSinceNow]);
    delta -= [[NSTimeZone localTimeZone] secondsFromGMT];
    
    if (delta < 0)
    {
        return @"";
    }
    else if (delta < 60)
    {
        return [NSString stringWithFormat:@"%ds", delta];
    }
    else if (delta < 3600)
    {
        NSInteger mins = floor(delta / 60);
        return [NSString stringWithFormat:@"%dm", mins];
    }
    else if (delta < 86400)
    {
        NSInteger hours = floor(delta / 3600);
        return [NSString stringWithFormat:@"%dh", hours];
    }
    else if (delta < 604800) 
    {
        NSInteger days = floor(delta / 86400);
        return [NSString stringWithFormat:@"%dd", days];
    }
    else {
        NSInteger weeks = floor(delta / 604800);
        return [NSString stringWithFormat:@"%dw", weeks];
    }
}

@end
