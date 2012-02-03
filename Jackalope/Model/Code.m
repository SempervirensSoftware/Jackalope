//
//  Code.m
//  Touch Code
//
//  Created by Peter Terrill on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Code.h"
#import "NSAttributedString+Attributes.h"
#import "LineOfCode.h"

@implementation Code

@synthesize plainText = _plainText;
@synthesize fileName = _fileName;
@synthesize gitBlobSHA = _gitBlobSHA;

-(id) initWithPath:(NSString*)path AndContents:(NSString*)contents;
{
    self = [super init];
    
    if (self)
    {
        _plainText = contents;
        _fileName = path;
    }
    
    return self;
}
   
@end
