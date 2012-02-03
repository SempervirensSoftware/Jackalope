//
//  Branch.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchNode.h"

@implementation BranchNode

@synthesize commitSHA, rootTreeSHA;


-(NSString *)type
{
    return NODE_TYPE_BRANCH;
}

@end
