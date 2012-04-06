//
//  GitNode.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitNode.h"
#import "Error.h"

@implementation GitNode

@synthesize name, fullPath, type, children, operationQueue;
@synthesize sha = _sha;

const int _maxRefreshCount = 1;

- (id) init
{
    self = [super init];
    if (self)
    {
        _refreshRetryCount = 0;
    }
    
    return  self;
}


- (void) refresh
{
    NSString* urlString = [self appendUrlParamsToString:[self updateURL]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:req queue:self.operationQueue completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         NSNotification* note = nil;
         if (error)
         {
             note = [NSNotification notificationWithName:NODE_UPDATE_FAILED object:self userInfo:nil];
             NSLog(@"Error loading %@@%@ : %@", self.type, [req.URL absoluteString], [error localizedDescription]);
         }
         else
         {             
             NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

             SBJSON *jsonParser = [SBJSON new];
             id responseObject = (NSArray *) [jsonParser objectWithString:responseString];

             if ([self validateRefreshResponse:responseObject])
             {
                 [self setValuesFromRefreshResponse:responseObject];                                          
                 note = [NSNotification notificationWithName:NODE_UPDATE_SUCCESS object:self userInfo:nil];                
             }
             else {
                 if (_refreshRetryCount > 0){
                     note = [NSNotification notificationWithName:NODE_UPDATE_RETRY object:self userInfo:nil];                
                     NSLog(@"Retry loading %@@%@ : %@", self.type, [req.URL absoluteString], [error localizedDescription]);                     
                 }
                 else {
                     note = [NSNotification notificationWithName:NODE_UPDATE_FAILED object:self userInfo:nil];                
                     NSLog(@"Server Error loading %@@%@", self.type, [req.URL absoluteString]);
                 }
             }
         }

         [[NSNotificationCenter defaultCenter] postNotification:note];
     }];
    
    NSLog(@"refresh%@@%@", self.type, urlString);
}

- (BOOL) validateRefreshResponse:(id)responseObject
{
    if (!responseObject) { 
        _refreshRetryCount = 0;
        return NO; 
    }

    if ([responseObject isMemberOfClass:[NSDictionary class]])
    {
        NSDictionary* error = [(NSDictionary*)responseObject objectForKey:@"error"];
        
        if (error){
            int errorCode = [((NSString *)[error objectForKey:@"code"]) intValue];
            NSLog(@"Error Refreshing Data (%d)", errorCode);
            
            switch (errorCode) {
                case ERROR_USER_NOT_FOUND:
                case ERROR_PARAM_TOKEN_NOT_FOUND:
                    [CurrentUser logout];
                    [GlobalAppDelegate showLogin];
                    _refreshRetryCount = 0;
                    break;                    
                default:
                    // try again
                    if (_refreshRetryCount <= _maxRefreshCount){
                        // the counter should be incremented before calling refresh
                        _refreshRetryCount++;
                        [self refresh];
                    }
                    else {
                        _refreshRetryCount = 0;
                    }
                    break;
            }
            
            return NO;
        }
    }
    
    _refreshRetryCount =  0;
    return YES;
}

- (NSString *) appendUrlParamsToString:(NSString *)baseURL
{
    return [NSString stringWithFormat:@"%@?token=%@",baseURL, CurrentUser.githubToken];
}

- (void) setSha:(NSString *)sha
{
    if (!_sha)
    {
        _sha = sha;
    }
    else if (_sha && ![_sha isEqualToString:sha])
    {
        _sha = sha;
        [self refresh];
    }
}

- (NSComparisonResult)compare:(GitNode *)otherObject {
    if ([self.type isEqualToString:otherObject.type])
    {
        return [self.name compare:otherObject.name];
    }
    else if ([self.type isEqualToString:NODE_TYPE_TREE])
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedDescending;
    }
}

// Override methods for the next generation
- (void)        setValuesFromRefreshResponse:(NSString *) jsonString {}
- (void)        setValuesFromDictionary:(NSDictionary *) valueMap {}
- (NSString*)   updateURL { return nil; }

// some constants for the GitNode world
NSString *const NODE_TYPE_ROOT = @"root";
NSString *const NODE_TYPE_REPO = @"repo";
NSString *const NODE_TYPE_BRANCH = @"branch";
NSString *const NODE_TYPE_TREE = @"tree";
NSString *const NODE_TYPE_BLOB = @"blob";

NSString *const NODE_COMMIT_SUCCESS = @"cS";
NSString *const NODE_COMMIT_FAILED = @"cF";

NSString *const NODE_UPDATE_SUCCESS = @"uS";
NSString *const NODE_UPDATE_RETRY = @"uR";
NSString *const NODE_UPDATE_FAILED = @"uF";

@end
