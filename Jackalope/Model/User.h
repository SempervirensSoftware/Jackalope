//
//  User.h
//  Jackalope
//
//  Created by Peter Terrill on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* githubUserName;
@property(nonatomic, retain) NSString* githubToken;

@end
