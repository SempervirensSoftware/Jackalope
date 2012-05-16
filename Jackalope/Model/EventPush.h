//
//  EventPush.h
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@interface EventPush : Event

@property (retain, nonatomic)           NSArray*           commits;
@property (retain, nonatomic)           NSString*          ref;

@end
