//
//  FeedItem.h
//  Jackalope
//
//  Created by Peter Terrill on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedItem : NSObject

@property (retain, nonatomic)           NSString*           message;
@property (retain, nonatomic)           NSString*           username;

- (id) initWithDictionary:(NSDictionary*)values;

@end