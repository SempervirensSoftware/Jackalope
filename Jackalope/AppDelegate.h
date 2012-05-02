//
//  AppDelegate.h
//  Jackalope
//
//  Created by Peter Terrill on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL        _iPhoneDevice;
}

@property (strong, nonatomic)           UIWindow*               window;
@property (strong, nonatomic)           UITabBarController*     tabBarController;
@property (strong, nonatomic)           UISplitViewController*  splitViewController;
@property (strong, readonly, nonatomic) NSString*               deviceToken;

-(void) userLoggedIn;
-(void) showLogin;
-(void) showApp;

@end
