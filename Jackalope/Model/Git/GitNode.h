//
//  GitNode.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"

@interface GitNode : NSObject
{
    int _refreshRetryCount;
}

@property (retain, nonatomic)           NSString*           sha;
@property (retain, nonatomic)           NSString*           name;
@property (retain, nonatomic)           NSString*           fullPath;
@property (retain, nonatomic, readonly) NSString*           type;
@property (retain, nonatomic)           NSOperationQueue*   operationQueue;
@property (retain, nonatomic)           NSArray*            children;

- (void)        refresh;
- (BOOL)        validateRefreshResponse:(id)responseObject;
- (NSString *)  appendUrlParamsToString:(NSString *)baseURL;

// ******************************************************************* //
//   These should be overriden as appropriate for the child classes
// ******************************************************************* //
- (void)        setValuesFromRefreshResponse:(id) responseObjects;
- (void)        setValuesFromDictionary:(NSDictionary *) valueMap;
- (NSString*)   updateURL;
// ******************************************************************* //

extern NSString *const NODE_TYPE_ROOT;
extern NSString *const NODE_TYPE_REPO;
extern NSString *const NODE_TYPE_BRANCH;
extern NSString *const NODE_TYPE_TREE;
extern NSString *const NODE_TYPE_BLOB;

extern NSString *const NODE_COMMIT_SUCCESS;
extern NSString *const NODE_COMMIT_FAILED;

extern NSString *const NODE_UPDATE_SUCCESS;
extern NSString *const NODE_UPDATE_RETRY;
extern NSString *const NODE_UPDATE_FAILED;

@end
