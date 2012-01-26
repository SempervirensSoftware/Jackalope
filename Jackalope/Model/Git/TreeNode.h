//
//  Tree.h
//  Touch Code
//
//  Created by Peter Terrill on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

extern NSString *const NODE_TYPE_BLOB;
extern NSString *const NODE_TYPE_TREE;
extern NSString *const NODE_TYPE_REPOS;
extern NSString *const NODE_TYPE_BRANCHES;

@property (retain, nonatomic) NSString      *name;
@property (retain, nonatomic) NSString      *fullPath;
@property (retain, nonatomic) NSString      *sha;
@property (retain, nonatomic) NSString      *parentSha;
@property (retain, nonatomic) NSString      *type;
@property (retain, nonatomic) NSString      *repoName;
@property (retain, nonatomic) NSString      *commit;
@property (retain, nonatomic) NSArray       *children;

- (id) parseTreeApiResponse:(NSString *) jsonString;

@end
