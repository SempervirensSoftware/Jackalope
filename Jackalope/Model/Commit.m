//
//  Commit.m
//  Jackalope
//
//  Created by Peter Terrill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Commit.h"
#import "CommitFile.h"
#import "SBJSON.h"

@implementation Commit

@synthesize authorName, authorEmail, message, files, repoName, repoOwner, date;

-(void) setValuesFromRefreshResponse:(id)responseObject
{
    if (![responseObject isKindOfClass:[NSDictionary class]])
    {  return; }
    NSDictionary* values = (NSDictionary*)responseObject;

    NSDictionary* commit = [values objectForKey:@"commit"];
    if (commit)
    {
        NSDictionary* committer = [commit objectForKey:@"committer"];
        if (committer)
        {
            NSString* dateStr = [committer objectForKey:@"date"];
            dateStr = [dateStr stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZ"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            self.date = [dateFormatter dateFromString:dateStr];
        }
    }
    
    NSMutableArray* tempFiles = [[NSMutableArray alloc] init];  
    NSArray* fileArray = [values objectForKey:@"files"];
    for (NSDictionary* fileMap in fileArray)
    {
        CommitFile* tempFile = [[CommitFile alloc] initWithDictionary:fileMap];
        NSString* fileName = [tempFile.name lastPathComponent];
        if ([fileName characterAtIndex:0] != '.')
        {
            [tempFiles addObject:tempFile];
        }
    }
    self.files = tempFiles;
}

- (void) setValuesFromDictionary:(NSDictionary *)valueMap
{
    self.sha = [valueMap objectForKey:@"sha"];
    self.message = [valueMap objectForKey:@"message"];                
    self.authorName = [valueMap objectForKey:@"authorName"];
    self.authorEmail = [valueMap objectForKey:@"authorEmail"];
}

- (NSString*)   updateURL
{
   return [NSString stringWithFormat:@"%@/repo/%@/%@/commit/%@.json", kServerRootURL, self.repoOwner, self.repoName, self.sha]; 
}

-(NSString *)type
{
    return NODE_TYPE_COMMIT;
}


@end
