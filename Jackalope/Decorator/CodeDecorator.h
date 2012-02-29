//
//  CodeDecorator.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeDecorator : NSObject
{
            NSMutableArray*                 _decorations;
            NSError*                        _regexError;
    __block NSMutableAttributedString*      processingAttributedString;
}

-(id) initFromDictionary:(NSDictionary *)dict andTheme:(NSMutableDictionary *)initTheme;

-(NSAttributedString *) decorateString:(NSString *)code;
-(NSAttributedString *) decorateAttributedString:(NSAttributedString *)code;

+(UIColor *) colorForHexString:(NSString *)hexString;

@property (strong, nonatomic, readonly) NSString*        name;
@property (strong, nonatomic, readonly) NSArray*         extensions;
@property (strong, nonatomic)           NSDictionary*    theme;

@end
