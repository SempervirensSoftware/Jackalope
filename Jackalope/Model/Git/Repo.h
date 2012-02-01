//
//  Repo.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repo : NSObject
{
    NSMutableDictionary *_treeHash;    
}

@property (retain) NSString* repoName;
@property (retain) NSString* repoRootSHA;

@end
