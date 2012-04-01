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

@synthesize githubToken = _githubToken;
@synthesize githubUserName = _githubUserName;


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
        _githubToken = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubTokenPrefKey];
        _githubUserName = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubUserNamePrefKey];        
        
        NSLog(@"loadUser: %@(%@)", self.githubUserName, self.githubToken);
        [TestFlight passCheckpoint:@"AutoLogin"];
    }
    
    return self;
}

-(BOOL) isLoggedIn{
    if (self.githubToken && self.githubUserName){
        return YES;
    }
    
    return NO;
}

-(void) loginWithToken:(NSString *)token andUserName:(NSString *)userName
{
    self.name = userName;
    self.githubUserName = userName;
    self.githubToken = token;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) logout
{
    self.name = nil;
    self.githubToken = nil;
    self.githubUserName = nil;

    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setGithubToken:(NSString *)githubToken
{
    _githubToken = githubToken;

    if (githubToken)
    {
        [[NSUserDefaults standardUserDefaults] setObject:githubToken forKey:JackalopeGithubTokenPrefKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JackalopeGithubTokenPrefKey];
    }    
}

-(void) setGithubUserName:(NSString *)githubUserName
{
    _githubUserName = githubUserName;
    
    if (githubUserName)
    {
        [[NSUserDefaults standardUserDefaults] setObject:githubUserName forKey:JackalopeGithubUserNamePrefKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JackalopeGithubUserNamePrefKey];
    }
}

@end
