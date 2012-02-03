//
//  GitNodeProvider.h
//  Jackalope
//
//  Created by Peter Terrill on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"

@protocol GitNodeProvider <NSObject>

-(GitNode *) getTreeNodeWithSHA:(NSString *) sha;
-(GitNode *) getBlobNodeWithSHA:(NSString *) sha;

@end
