//
//  Commit.h
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"

@interface BlobCommit : NSObject
{
    // http handlers
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSMutableDictionary *_treeHash;  
}

- (id) initWithBlob:(TreeNode *)blob;

@property (retain, nonatomic) NSString      *blobName;
@property (retain, nonatomic) NSString      *blobFullPath;
@property (retain, nonatomic) NSString      *blobSHA;
@property (retain, nonatomic) NSString      *blobContent;

@property (retain, nonatomic) NSString      *repoName;
@property (retain, nonatomic) NSString      *repoRootSHA;
@property (retain, nonatomic) NSString      *commitSHA;
@property (retain, nonatomic) NSString      *treeSHA;

- (NSURLRequest *) urlRequest;
- (NSData *) httpBody;
- (void) send;

@end
