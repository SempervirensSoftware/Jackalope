//
//  GitNode.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitNode.h"
#import "AppUser.h"

@implementation GitNode

@synthesize name, fullPath, type, children, operationQueue;
@synthesize sha = _sha;

- (void) refreshData
{
    NSString* urlString = [self appendUrlParamsToString:[self updateURL]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:req queue:self.operationQueue completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
        if (error)
        {
            NSNotification *note = [NSNotification notificationWithName:NODE_UPDATE_FAILED
                                                                 object:self
                                                               userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:note];
            
            NSLog(@"Error loading %@@%@ : %@", self.type, [req.URL absoluteString], [error localizedDescription]);
        }
        else
        {
            // We are just checking to make sure we are getting the XML
            NSString *responseString = [[NSString alloc] initWithData:data
                                                             encoding:NSUTF8StringEncoding];
            
            [self setValuesFromApiResponse:responseString];                          
            
            NSNotification *note = [NSNotification notificationWithName:NODE_UPDATE_SUCCESS
                                                                 object:self
                                                               userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
     }];
    
    NSLog(@"refresh%@@%@", self.type, urlString);
}

- (NSString *) appendUrlParamsToString:(NSString *)baseURL
{
    return [NSString stringWithFormat:@"%@?token=%@&gitUserName=%@",baseURL, [AppUser currentUser].githubToken, [AppUser currentUser].githubUserName];
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
        [self refreshData];
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
- (void)        setValuesFromApiResponse:(NSString *) jsonString {}
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
NSString *const NODE_UPDATE_FAILED = @"uF";

@end
