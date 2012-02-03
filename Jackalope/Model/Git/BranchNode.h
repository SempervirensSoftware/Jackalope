//
//  Branch.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"

@interface BranchNode : GitNode

@property (nonatomic, retain) NSString* commitSHA;
@property (nonatomic, retain) NSString* rootTreeSHA;

@end
