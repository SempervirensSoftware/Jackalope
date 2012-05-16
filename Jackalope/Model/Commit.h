//
//  Commit.h
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commit : NSObject

@property (retain, nonatomic)           NSString*           sha;
@property (retain, nonatomic)           NSString*           message;
@property (retain, nonatomic)           NSString*           authorEmail;
@property (retain, nonatomic)           NSString*           authorName;

- (id) initWithDictionary:(NSDictionary*)values;

@end
