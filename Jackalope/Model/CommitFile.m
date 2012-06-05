//
//  CommitFile.m
//  Jackalope
//
//  Created by Peter Terrill on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommitFile.h"

@implementation CommitFile

@synthesize sha,name,patch,status,adds,deletes;

- (id) initWithDictionary:(NSDictionary*)values
{
    self = [super init];
    
    if (self)
    {
        self.sha = [values objectForKey:@"sha"];
        self.name = [values objectForKey:@"filename"];
        self.status = [values objectForKey:@"status"];
        self.patch = [values objectForKey:@"patch"];
        self.adds = [[values objectForKey:@"additions"] integerValue];
        self.deletes = [[values objectForKey:@"deletions"] integerValue];
    }
    
    return self;
}

@end
