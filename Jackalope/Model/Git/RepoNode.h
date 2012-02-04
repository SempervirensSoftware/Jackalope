//
//  Repo.h
//  Jackalope
//
//  Created by Peter Terrill on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitNodeProvider.h"

@interface RepoNode : GitNode <GitNodeProvider>
{    
    NSMutableDictionary*    _nodeHash;        
}

@property (nonatomic)           BOOL        isPrivate;
@property (retain, nonatomic)   NSString*   masterBranch;

@end
