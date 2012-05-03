//
//  AppDelegate.m
//  Jackalope
//
//  Created by Peter Terrill on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CodeViewController.h"
#import "GithubLoginViewController.h"
#import "AppModesTabBarController.h"
#import "RepoViewController.h"

@interface AppDelegate ()

-(void) handleNotification:(NSDictionary *)notificationInfo;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize splitViewController = _splitViewController;
@synthesize deviceToken = _deviceToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [TestFlight takeOff:@"18ab5f338e897f1dd26b820d861ca021_NjAxODYyMDEyLTAyLTIzIDIzOjUzOjMyLjUzNTQwNQ"];
    BOOL isLoggedIn = CurrentUser.isLoggedIn;
    
    CodeViewController* codeViewController;
    AppModesTabBarController* appTab = [[AppModesTabBarController alloc] init];    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _iPhoneDevice = YES;
        
        codeViewController = [[CodeViewController alloc] initWithNibName:@"CodeView_iPhone" bundle:nil];        
        
        self.tabBarController = appTab;        
    } 
    else 
    {
        _iPhoneDevice = NO;
        
        codeViewController = [[CodeViewController alloc] initWithNibName:@"CodeView_iPad" bundle:nil];        
        UINavigationController *detailViewNav = [[UINavigationController alloc] initWithRootViewController:codeViewController];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = codeViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:appTab, detailViewNav, nil];
    }
                                                
    [RepoViewController getInstance].codeViewController = codeViewController;

    //Setup the app for notifications
    UIRemoteNotificationType noteTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
    [application registerForRemoteNotificationTypes:noteTypes];
    [self handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    if (isLoggedIn)
    {
        [self userLoggedIn];
        [TestFlight passCheckpoint:@"AutoLogin"];
    }
    else
    {
        [self showLogin];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) userLoggedIn
{
    [self showApp];
}

-(void) showApp
{
    if (_iPhoneDevice)
    {
        self.window.rootViewController = self.tabBarController;
    }
    else
    {
        self.window.rootViewController = self.splitViewController;
    }
}

-(void) showLogin
{
    NSString* loginNib = @"GithubLogin_iPhone";
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        loginNib = @"GithubLogin_iPad";
    }
    
    UIViewController* loginController = [[GithubLoginViewController alloc] initWithNibName:loginNib bundle:nil];
    self.window.rootViewController = loginController;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tempToken = [deviceToken description];
    tempToken = [tempToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tempToken = [tempToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    _deviceToken = tempToken;
    
    if (CurrentUser.isLoggedIn){
        CurrentUser.deviceToken = _deviceToken;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"RemoteNotificationRegFailure:%@",[error localizedDescription]); 
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleNotification:userInfo];
}
-(void) handleNotification:(NSDictionary *)notificationInfo
{
    if (!notificationInfo)
    { return; }
    
    // TODO handle notification
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
