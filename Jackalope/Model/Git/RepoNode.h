//
//  Repo.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"

@interface RepoNode : GitNode

@property (nonatomic)           BOOL        isPrivate;
@property (retain, nonatomic)   NSString*   repoOwner;
@property (retain, nonatomic)   NSString*   masterBranch;

@end
