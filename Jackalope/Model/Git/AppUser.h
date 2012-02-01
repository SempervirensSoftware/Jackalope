//
//  User.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AppUser : NSObject

+(AppUser *) currentUser;

@property(nonatomic, retain) User* user;

@end
