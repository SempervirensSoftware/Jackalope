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
NSString * const JackalopeGithubUserNamePrefKey = @"JackalopeGithubUserNamePrefKey";

@implementation AppUser

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
        self.githubToken = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubTokenPrefKey];
        self.githubUserName = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubUserNamePrefKey];        
        
        NSLog(@"loadUser: %@(%@)", self.githubUserName, self.githubToken);
        [TestFlight passCheckpoint:@"AutoLogin"];
    }
    
    return self;
}

-(void) setGithubToken:(NSString *)githubToken
{
    [super setGithubToken:githubToken];
    [[NSUserDefaults standardUserDefaults] setValue:githubToken forKey:JackalopeGithubTokenPrefKey];
}

-(void) setGithubUserName:(NSString *)githubUserName
{
    [super setGithubUserName:githubUserName];
    [[NSUserDefaults standardUserDefaults] setValue:githubUserName forKey:JackalopeGithubUserNamePrefKey];
}

@end
