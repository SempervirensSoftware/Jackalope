//
//  Commit.h
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"

@interface Commit : GitNode

@property (retain, nonatomic)           NSDate*             date;
@property (retain, nonatomic)           NSString*           message;
@property (retain, nonatomic)           NSString*           repoOwner;
@property (retain, nonatomic)           NSString*           repoName;
@property (retain, nonatomic)           NSString*           authorEmail;
@property (retain, nonatomic)           NSString*           authorName;
@property (retain, nonatomic)           NSArray*            files;

@end
