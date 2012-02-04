//
//  GitNode.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"
#import "AppUser.h"

@interface GitNode : NSObject
{
    NSURLConnection *_connection;
    NSMutableData *_responseData;
}

@property (retain, nonatomic)           NSString*     sha;
@property (retain, nonatomic)           NSString*     name;
@property (retain, nonatomic)           NSString*     fullPath;
@property (retain, nonatomic, readonly) NSString*     type;
@property (retain, nonatomic)           NSArray*      children;

- (void)        refreshData;

// ******************************************************************* //
//   These should be overriden as appropriate for the child classes
// ******************************************************************* //
- (void)          setValuesFromApiResponse:(NSString *) jsonString;
- (void)          setValuesFromDictionary:(NSDictionary *) valueMap;
- (NSString*)   updateURL;

extern NSString *const NODE_TYPE_ROOT;
extern NSString *const NODE_TYPE_REPO;
extern NSString *const NODE_TYPE_BRANCH;
extern NSString *const NODE_TYPE_TREE;
extern NSString *const NODE_TYPE_BLOB;

extern NSString *const NODE_UPDATE_SUCCESS;
extern NSString *const NODE_UPDATE_FAILED;

@end
