//
//  Commit.h
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"
#import "Code.h"

@interface BlobNode : TreeNode

@property (retain, nonatomic) NSString      *fileContent;

-(Code *) createCode;

@end
