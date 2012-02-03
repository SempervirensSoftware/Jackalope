//
//  GitNode.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitNode.h"

@implementation GitNode

@synthesize sha, name, fullPath, type, parentSha, commit, children;

- (void) refreshData
{
    _responseData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:[self updateURL]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    _connection = [[NSURLConnection alloc] initWithRequest:req
                                                  delegate:self
                                          startImmediately:YES];
}

// This method will be called several times as the data arrives
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the incoming chunk of data to the container we are keeping
    // The data always comes in the correct order
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // We are just checking to make sure we are getting the XML
    NSString *responseString = [[NSString alloc] initWithData:_responseData
                                                     encoding:NSUTF8StringEncoding];
    
    [self setValuesFromApiResponse:responseString];                          
    
    NSNotification *note = [NSNotification notificationWithName:NODE_UPDATE_SUCCESS
                                                         object:self
                                                       userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    
    // Release the connection and response data, we're done with it
    _connection = nil;
    _responseData = nil;    
}

- (void)connection:(NSURLConnection *)conn
  didFailWithError:(NSError *)error
{
    // Release the connection and response data, we're done with it
    _connection = nil;
    _responseData = nil;
    
    NSNotification *note = [NSNotification notificationWithName:NODE_UPDATE_FAILED
                                                         object:self
                                                       userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    NSLog(@"Error loading %@@%@ : %@", self.type, [conn.originalRequest.URL description], [error localizedDescription]);
}

// Override methods for the next generation
- (void)        setValuesFromApiResponse:(NSString *) jsonString {}
- (void)        setValuesFromDictionary:(NSDictionary *) valueMap {}
- (NSString*)   updateURL { return nil; }


// some constants for the GitNode world
NSString *const NODE_TYPE_ROOT = @"root";
NSString *const NODE_TYPE_REPO = @"repo";
NSString *const NODE_TYPE_BRANCH = @"branch";
NSString *const NODE_TYPE_TREE = @"tree";
NSString *const NODE_TYPE_BLOB = @"blob";
NSString *const NODE_UPDATE_SUCCESS = @"success";
NSString *const NODE_UPDATE_FAILED = @"failed";

@end
