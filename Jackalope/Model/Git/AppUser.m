//
//  User.m
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppUser.h"

static AppUser* _instance = nil;
NSString * const JackalopeGithubTokenPrefKey = @"JackalopeGithubTokenPrefKey";

@implementation AppUser

@synthesize user = _user;

+ (AppUser *) currentUser
{
    if (!_instance) {
        // Create the singleton
        _instance = [[super allocWithZone:NULL] init];
    }
    
    return _instance;
}

// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self currentUser];
}

- (id)init {
    
    if (_instance) {
        return _instance;
    }
    
    // create a new instance
    self = [super init];
    
    if (self)
    {
        NSString* githubToken = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubTokenPrefKey];
        
        if (githubToken)
        {
            User* user = [[User alloc] init]; 
            user.githubToken = githubToken;
            self.user = user;
        }
        else
        {
            _user = nil;
        }
    }
    
    return self;
}

@end
