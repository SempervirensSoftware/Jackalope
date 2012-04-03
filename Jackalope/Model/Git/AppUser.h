//
//  User.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AppUser : User

+(AppUser *) currentUser;

@property(nonatomic, readonly, retain) NSString* githubUserName;
@property(nonatomic, readonly, retain) NSString* githubToken;

-(void) loginWithToken:(NSString *)token email:(NSString *)email andUserName:(NSString *)userName;
-(void) logout;
-(BOOL) isLoggedIn;

@end
