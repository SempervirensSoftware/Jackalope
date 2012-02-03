//
//  Code.h
//  Touch Code
//
//  Created by Peter Terrill on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#include <CoreFoundation/CFAttributedString.h>

@interface Code : NSObject

-(id) initWithPath:(NSString*)path AndContents:(NSString*)contents;

@property(nonatomic, retain)            NSString* gitBlobSHA;
@property(nonatomic, strong, readonly)  NSString* fileName;
@property(nonatomic, retain)            NSString* plainText;

@end
