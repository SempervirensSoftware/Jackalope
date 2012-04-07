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
NSString * const JackalopeEmailPrefKey = @"JackalopeEmailPrefKey";

@implementation AppUser

@synthesize githubToken = _githubToken;
@synthesize githubUserName = _githubUserName;
@synthesize email = _email;

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
        _githubToken    = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubTokenPrefKey];
        _githubUserName = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeGithubUserNamePrefKey];        
        _email          = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeEmailPrefKey];
        
        NSLog(@"loadUser: %@(%@)", self.githubUserName, self.githubToken);
    }
    
    return self;
}

-(BOOL) isLoggedIn{
    if (self.githubToken && self.githubUserName && self.email){
        return YES;
    }
    
    return NO;
}

-(void) loginWithToken:(NSString *)token email:(NSString *)Email andUserName:(NSString *)userName
{
    self.name = userName;
    self.githubUserName = userName;
    self.githubToken = token;
    self.email = Email;

    NSNotification* note = [NSNotification notificationWithName:APPUSER_LOGIN object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) logout
{
    NSLog(@"logout (%@)",self.name);
    
    self.name = nil;
    self.githubToken = nil;
    self.githubUserName = nil;
    self.email = nil;

    NSNotification* note = [NSNotification notificationWithName:APPUSER_LOGOUT object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
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

-(void) setEmail:(NSString *)email
{
    _email = email;
    
    if (email)
    {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:JackalopeEmailPrefKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JackalopeEmailPrefKey];
    }
}

NSString *const APPUSER_LOGIN = @"aIN";
NSString *const APPUSER_LOGOUT = @"aOUT";

@end
