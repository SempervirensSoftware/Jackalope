//
//  User.m
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppUser.h"
#import "UIDevice+IdentifierAddition.h"

static AppUser* _instance = nil;
NSString * const JackalopeGithubTokenPrefKey = @"JackalopeGithubTokenPrefKey";
NSString * const JackalopeGithubUserNamePrefKey = @"JackalopeGithubUserNamePrefKey";
NSString * const JackalopeDeviceTokenPrefKey = @"JackalopeDeviceTokenPrefKey";
NSString * const JackalopeEmailPrefKey = @"JackalopeEmailPrefKey";

@implementation AppUser

@synthesize githubToken = _githubToken;
@synthesize githubUserName = _githubUserName;
@synthesize deviceToken = _deviceToken;
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
        //_deviceToken    = [[NSUserDefaults standardUserDefaults] objectForKey:JackalopeDeviceTokenPrefKey];
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
    self.deviceToken = GlobalAppDelegate.deviceToken;

    if ([self isLoggedIn]){
        NSNotification* note = [NSNotification notificationWithName:APPUSER_LOGIN object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        [[NSUserDefaults standardUserDefaults] synchronize];        
    }
}

-(void) logout
{
    NSLog(@"logout (%@)",self.name);
    
    self.name = nil;
    self.githubToken = nil;
    self.githubUserName = nil;
    self.email = nil;
    self.deviceToken = nil;

    NSNotification* note = [NSNotification notificationWithName:APPUSER_LOGOUT object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) appendAuthTokenToUrlString:(NSString *)urlString
{
    NSRange qmarkRange = [urlString rangeOfString:@"?"];
    NSString* paramSeperator = @"&";

    if (qmarkRange.location == NSNotFound)
    {
        paramSeperator = @"?";
    }
    
    return [NSString stringWithFormat:@"%@%@token=%@",urlString,paramSeperator,self.githubToken];
}


-(void) setGithubToken:(NSString *)githubToken
{
    // Don't need to update everything if the value hasn't changed
    if ([githubToken isEqualToString:_githubToken])
    { return; }

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
    // Don't need to update everything if the value hasn't changed
    if ([githubUserName isEqualToString:_githubUserName])
    { return; }
    
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
    // Don't need to update everything if the value hasn't changed
    if ([email isEqualToString:_email])
        { return; }

    _email = email;    
    if (email)
    {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:JackalopeEmailPrefKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JackalopeEmailPrefKey];
    }
}

-(void) setDeviceToken:(NSString*)deviceToken
{
    // Don't need to update everything if the value hasn't changed
    if ([deviceToken isEqualToString:_deviceToken])
        { return; }
    
    if (!deviceToken)
    {
        _deviceToken = deviceToken;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JackalopeDeviceTokenPrefKey];
        return;
    }
        
    NSString* urlString = [CurrentUser appendAuthTokenToUrlString:[NSString stringWithFormat:@"%@/user/apns?apnsToken=%@&deviceId=%@", kServerRootURL, deviceToken, [[UIDevice currentDevice] uniqueDeviceIdentifier]]];
    NSURL *url = [NSURL URLWithString:urlString];     
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         if (error || ( ((NSHTTPURLResponse*)response).statusCode != 200) )
         {
             NSLog(@"APNS Registration Error:(%d) %@", ((NSHTTPURLResponse*)response).statusCode, [error.userInfo objectForKey:@"NSLocalizedDescription"]);                 
             return;
         }
         else
         {
             _deviceToken = deviceToken;
             [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:JackalopeDeviceTokenPrefKey];
             return;
         }
     }];
}


NSString *const APPUSER_LOGIN = @"aIN";
NSString *const APPUSER_LOGOUT = @"aOUT";

@end
