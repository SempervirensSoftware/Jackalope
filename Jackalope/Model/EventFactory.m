//
//  EventFactory.m
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventFactory.h"

@implementation EventFactory

+ (Event*) createEventForDictionary:(NSDictionary*)values
{
    NSString* type = [values objectForKey:@"type"];
    Event* event = nil;
    
    if ([type isEqualToString:@"PushEvent"])
    {
        event = [[EventPush alloc] initWithDictionary:values];
    }
    else {
        event = [[Event alloc] initWithDictionary:values];
    }
                 
    return event;
}


@end
