//
//  AppModesTabBarController.m
//  Jackalope
//
//  Created by Peter Terrill on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppModesTabBarController.h"
#import "RepoViewController.h"
#import "FeedViewController.h"

@interface AppModesTabBarController ()
-(void) customInit;
@end

@implementation AppModesTabBarController

- (void) customInit{
    UINavigationController* repoNavController = [RepoViewController getInstance].navController;
    repoNavController.title = nil;
    [[RepoViewController getInstance] showRootNode];
    
    FeedViewController* feedController = [[FeedViewController alloc] init];
    
    NSArray* modesArray = [[NSArray alloc] initWithObjects:feedController, repoNavController, nil];
    self.viewControllers = modesArray;
}

- (id)init{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
