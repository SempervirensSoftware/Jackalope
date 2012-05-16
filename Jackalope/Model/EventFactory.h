//
//  EventFactory.h
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "EventPush.h"

@interface EventFactory : NSObject

+ (Event*) createEventForDictionary:(NSDictionary*)values;

@end
