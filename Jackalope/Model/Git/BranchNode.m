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
- (void)            setValuesFromCommitResponse:(NSString*)response;
- (NSURLRequest *)  commitRequestForBlob:(BlobNode*)blob;
- (NSData *)        commitBodyForBlob:(BlobNode*)blob;
@end

@implementation BranchNode

@synthesize repoName, headCommitSHA, rootTree;

-(void) commonInit
{
    _nodeHash = [[NSMutableDictionary alloc] init];
}

-(id) init
{
    self = [super init];
    if (self){
        [self commonInit];
    }
    return self;
}

-(void) commitBlobNode:(GitNode*)blob
{
    NSURLRequest* commitRequest = [self commitRequestForBlob:(BlobNode*) blob];
    [NSURLConnection sendAsynchronousRequest:commitRequest queue:self.operationQueue completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         if (error)
         {             
             NSNotification *note = [NSNotification notificationWithName:NODE_COMMIT_FAILED
                                                                  object:blob
                                                                userInfo:nil];
             
             [[NSNotificationCenter defaultCenter] postNotification:note];
             
             NSLog(@"Error committing %@ : %@", self.fullPath, [error localizedDescription]);

         }
         else
         {
             NSString *responseString = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
             [self setValuesFromCommitResponse:responseString];
             
             NSNotification *note = [NSNotification notificationWithName:NODE_COMMIT_SUCCESS
                                                                  object:blob
                                                                userInfo:nil];
             
             [[NSNotificationCenter defaultCenter] postNotification:note];             
         }         
     }];
}

- (NSURLRequest *) commitRequestForBlob:(BlobNode*)blob
 {    
     NSString* urlString = [self appendUrlParamsToString:[NSString stringWithFormat:@"%@/repo/%@/tree",kServerRootURL,self.repoName]];
     NSLog(@"commitBlob:%@", blob.fullPath);

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

- (void) setValuesFromCommitResponse:(NSString*)jsonString
{
    SBJSON* jsonParser = [SBJSON new];
    NSDictionary* commitHash = (NSDictionary *) [jsonParser objectWithString:jsonString];

    if ([commitHash objectForKey:@"sha"]){
        self.headCommitSHA = [commitHash objectForKey:@"sha"];

    }
    if ([commitHash objectForKey:@"tree"]){
        NSDictionary* treeHash = [commitHash objectForKey:@"tree"];
        
        if ([treeHash objectForKey:@"sha"]){
            self.rootTree.sha = [treeHash objectForKey:@"sha"];        
        }
    }
}

-(GitNode *) getTreeNodeWithPath:(NSString *)fullNodePath
{
    TreeNode* node = [_nodeHash objectForKey:fullNodePath];
    
    if (!node)
    {
        node = [[TreeNode alloc] init];
        node.fullPath = fullNodePath;
        node.parentBranch = self;
        node.operationQueue = self.operationQueue;
        [_nodeHash setObject:node forKey:fullNodePath];
    }
    
    return node;
}

-(GitNode *) getBlobNodeWithPath:(NSString *)fullNodePath
{
    BlobNode* node = [_nodeHash objectForKey:fullNodePath];
    
    if (!node)
    {
        node = [[BlobNode alloc] init];
        node.fullPath = fullNodePath;
        node.parentBranch = self;
        node.operationQueue = self.operationQueue;
        [_nodeHash setObject:node forKey:fullNodePath];
    }
    
    return node;
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
    TreeNode* rootNode = (TreeNode*)[self getTreeNodeWithPath:@""];
    [rootNode setValuesFromApiResponse:jsonString];
    self.rootTree = rootNode;    
}

-(NSArray *) children
{
    return self.rootTree.children;
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"%@/repo/%@/branches/%@.json", kServerRootURL, self.repoName, self.headCommitSHA];
}

-(NSString *)type
{
    return NODE_TYPE_BRANCH;
}

@end
