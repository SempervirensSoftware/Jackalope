//
//  Branch.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchNode.h"
#import "BlobNode.h"

@interface BranchNode ()
- (NSString *)      appendUrlParamsToString:(NSString *)baseURL; // private method implemented in GitNode

- (NSURLRequest *)  commitRequestForBlob:(BlobNode*)blob;
- (NSData *)        commitBodyForBlob:(BlobNode*)blob;
@end

@implementation BranchNode

@synthesize repoName, nodeProvider, headCommitSHA, rootTree;

-(void) commitBlobNode:(GitNode*)blob
{
    NSURLRequest* commitRequest = [self commitRequestForBlob:(BlobNode*) blob];
    [NSURLConnection sendAsynchronousRequest:commitRequest queue:self.operationQueue completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         UIAlertView* av;
         
         if (error)
         {
             av = [[UIAlertView alloc] initWithTitle:@"Commit Failed"
                                             message:@"There was a problem committing your changes. Please try again." 
                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         }
         else
         {
             av = [[UIAlertView alloc] initWithTitle:@"Success!"
                                             message:@"Your changes were successfully committed to GitHub" 
                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         }
         
         [av show];
     }];
}

- (NSURLRequest *) commitRequestForBlob:(BlobNode*)blob
 {    
     NSString* urlString = [self appendUrlParamsToString:[NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/tree",self.repoName]];
     NSLog(@"commit@:%@", urlString);

     NSURL *url = [NSURL URLWithString:urlString];     
     NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
     
     [req setHTTPMethod:@"POST"];
     [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
     [req setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
     [req setHTTPBody: [self commitBodyForBlob:blob]];
     
     return req;
 }
 
- (NSData *) commitBodyForBlob:(BlobNode*)blob
 {     
     NSDictionary *map = [[NSDictionary alloc] initWithObjectsAndKeys:
     self.repoName, @"repoName", self.rootTree.sha, @"repoRootSHA", self.headCommitSHA, @"commitSHA", self.name, @"branchName",
     blob.name, @"blobName", blob.fullPath, @"blobFullPath", blob.sha, @"blobSHA", blob.fileContent, @"blobContent", nil];
     
     SBJSON *jsonWriter = [SBJSON new];
     NSString *jsonString = [jsonWriter stringWithObject:map];
     
     return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
 }
  
-(void) setValuesFromDictionary:(NSDictionary *)valueMap
{
    if ([valueMap objectForKey:@"name"]){
        self.name = [valueMap objectForKey:@"name"];
    }
    if ([valueMap objectForKey:@"commit"]){
        NSDictionary* commitHash = [valueMap objectForKey:@"commit"];
        
        if ([commitHash objectForKey:@"sha"]){
            self.headCommitSHA = [commitHash objectForKey:@"sha"];
        }
    }
}

-(void) setValuesFromApiResponse:(NSString *)jsonString
{
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *treeHash = (NSDictionary *) [jsonParser objectWithString:jsonString];
    
    TreeNode* rootNode = (TreeNode*)[self.nodeProvider getTreeNodeWithSHA:[treeHash objectForKey:@"sha"]];
    rootNode.parentBranch = self;
    rootNode.operationQueue = self.operationQueue;
    [rootNode setValuesFromApiResponse:jsonString];
    self.rootTree = rootNode;    
}

-(NSArray *) children
{
    return self.rootTree.children;
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"http://vivid-stream-9812.heroku.com/repo/%@/branches/%@.json", self.repoName, self.headCommitSHA];
}

-(NSString *)type
{
    return NODE_TYPE_BRANCH;
}

@end
