//
//  FeedItem.m
//  Jackalope
//
//  Created by Peter Terrill on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedItem.h"

@implementation FeedItem

@synthesize username, message;

- (id) initWithDictionary:(NSDictionary *)values
{
    self = [super init];
    
    if (self)
    {
        username = [values objectForKey:@"committerUsername"];
        message = [values objectForKey:@"message"];
    }
    
    return self;
}

@end
