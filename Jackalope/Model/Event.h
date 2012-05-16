//
//  Event.h
//  Jackalope
//
//  Created by Peter Terrill on 5/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (retain, nonatomic)           NSString*           eventId;
@property (retain, nonatomic)           NSString*           type;
@property (retain, nonatomic)           NSString*           actorLogin;
@property (retain, nonatomic)           NSString*           repoOwner;
@property (retain, nonatomic)           NSString*           repoName;
@property (retain, nonatomic)           NSString*           created_at;

- (id) initWithDictionary:(NSDictionary*)values;

@end
