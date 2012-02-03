//
//  Commit.m
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BlobNode.h"

#import "SBJSON.h"

@implementation BlobNode

@synthesize fileContent;

-(Code *) createCode
{
    Code* code = [[Code alloc] init];
    code.fileName = self.name;
    code.gitBlobSHA = self.sha;
    code.plainText = self.fileContent;
    
    return code;
}

-(void) setValuesFromApiResponse:(NSString *)jsonString
{
    self.fileContent = jsonString;
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/files/%@.json", self.repoName, self.sha];
}

-(NSString *)type
{
    return NODE_TYPE_BLOB;
}


/*
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
 */

@end
