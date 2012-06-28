//
//  CommitFile.h
//  Jackalope
//
//  Created by Peter Terrill on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommitFile : NSObject

@property (retain, nonatomic)           NSString*           sha;
@property (retain, nonatomic)           NSString*           name;
@property (retain, nonatomic)           NSString*           status;
@property (retain, nonatomic)           NSString*           patch;

@property (nonatomic)                   NSInteger           adds;
@property (nonatomic)                   NSInteger           deletes;
@property (nonatomic)                   BOOL                diffExpanded;

- (id) initWithDictionary:(NSDictionary*)values;

@end
