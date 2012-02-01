//
//  NSURL+PTQueryParsing.m
//  Jackalope
//
//  Created by Peter Terrill on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSURL+PTQueryParsing.h"

@implementation NSURL (PTQueryParsing)

-(NSString*) queryValueForKey:(NSString*)varName
{
    NSRange keyRange = [self.query rangeOfString:varName];

    if (keyRange.length == 0) 
    { 
        return nil; //the variable name doesn't exist in the query
    }
    
    NSInteger valueStartIndex = (keyRange.location + keyRange.length + 1); // +1 for the equals sign
    NSInteger valueLength = (self.query.length - valueStartIndex);
    
    NSRange nextVarRange = [self.query rangeOfString:@"&" options:0 range:NSMakeRange(valueStartIndex, valueLength)];
    if (nextVarRange.length != 0)
    {
        valueLength -= (self.query.length - nextVarRange.location);
    }
    
    return [self.query substringWithRange:NSMakeRange(valueStartIndex,valueLength)];
}

@end
