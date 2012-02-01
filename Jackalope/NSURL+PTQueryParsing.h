//
//  NSURL+PTQueryParsing.h
//  Jackalope
//
//  Created by Peter Terrill on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (PTQueryParsing)

-(NSString*) queryValueForKey:(NSString*)varName;

@end
