//
//  Commit.m
//  Touch Code
//
//  Created by Peter Terrill on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BlobNode.h"

@implementation BlobNode

@synthesize fileContent, commitMessage;

-(Code *) createCode
{
    Code* code = [[Code alloc] init];
    code.fileName = self.name;
    code.gitBlobSHA = self.sha;
    code.plainText = self.fileContent;
    
    return code;
}

-(void) commit
{
    [self.parentBranch commitBlobNode:self];
}

- (void) setValuesFromDictionary:(NSDictionary *) valueMap 
{
    [super setValuesFromDictionary:valueMap];
    
    if ([valueMap objectForKey:@"content"]){
        self.fileContent = [valueMap objectForKey:@"content"];
    }
}

-(void) setValuesFromRefreshResponse:(id)responseObject
{
    if (![responseObject isKindOfClass:[NSDictionary class]])
    {  return; }
    
    [self setValuesFromDictionary:(NSDictionary*) responseObject];
}

-(NSString *)updateURL
{
    return [NSString stringWithFormat:@"%@/repo/%@/%@/files/%@.json", kServerRootURL, self.parentBranch.repoOwner, self.parentBranch.repoName, self.sha];
}

-(NSString *)type
{
    return NODE_TYPE_BLOB;
}

@end
