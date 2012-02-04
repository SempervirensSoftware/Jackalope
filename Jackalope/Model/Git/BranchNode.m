//
//  Branch.m
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BranchNode.h"
#import "TreeNode.h"

@implementation BranchNode

@synthesize repoName, nodeProvider, headCommitSHA, rootTree;

-(void) commitBlobNode:(GitNode*)blob
{
    
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
