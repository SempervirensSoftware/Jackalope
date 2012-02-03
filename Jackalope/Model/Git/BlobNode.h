//
//  Commit.h
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNode.h"
#import "Code.h"

@interface BlobNode : GitNode
{
    // http handlers
    NSMutableDictionary *_treeHash;  
}

@property (retain, nonatomic) NSString      *blobName;
@property (retain, nonatomic) NSString      *blobFullPath;
@property (retain, nonatomic) NSString      *blobSHA;
@property (retain, nonatomic) NSString      *blobContent;

@property (retain, nonatomic) NSString      *repoName;
@property (retain, nonatomic) NSString      *repoRootSHA;
@property (retain, nonatomic) NSString      *commitSHA;
@property (retain, nonatomic) NSString      *treeSHA;


-(Code *) createCode;

- (NSURLRequest *) urlRequest;
- (NSData *) httpBody;
- (void) send;

@end
