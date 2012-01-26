//
//  Commit.m
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BlobCommit.h"

#import "SBJSON.h"

@implementation BlobCommit

@synthesize repoName, repoRootSHA, treeSHA, commitSHA, blobName, blobFullPath, blobSHA,  blobContent;

- (id) initWithBlob:(TreeNode *)blob{
    self = [super init];
    
    if (self)
    {
        self.repoName = blob.repoName;
        self.blobName = blob.name;
        self.blobFullPath = blob.fullPath;
        self.blobSHA = blob.sha;
        self.treeSHA = blob.parentSha;
        self.commitSHA = blob.commit;
        
        _responseData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (NSURLRequest *) urlRequest
{    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree",repoName]];
    
    NSLog(@"url:%@", url);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
    [req setHTTPBody: [self httpBody]];
    
    return req;
}

- (NSData *) httpBody
{
    NSData *returnData = nil;

    NSDictionary *map = [[NSDictionary alloc] initWithObjectsAndKeys:
                         repoName, @"repoName", repoRootSHA, @"repoRootSHA", treeSHA, @"treeSHA", commitSHA, @"commitSHA",
                         blobName, @"blobName", blobFullPath, @"blobFullPath", blobSHA, @"blobSHA", blobContent, @"blobContent", nil];
    
    SBJSON *jsonWriter = [SBJSON new];
    NSString *jsonString = [jsonWriter stringWithObject:map];
    NSLog(@"json:%@",jsonString);
    
    returnData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return returnData;
}

-(void) send
{
    _connection = [[NSURLConnection alloc] initWithRequest:[self urlRequest]
                                                  delegate:self
                                          startImmediately:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // Create and show an alert view with this error displayed
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success"
                                                 message:@"Your changes were successfully committed to GitHub"
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    
    [av show];

}



@end
