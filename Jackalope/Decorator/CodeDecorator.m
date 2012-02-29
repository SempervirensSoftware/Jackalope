//
//  CodeDecorator.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CodeDecorator.h"
#import "NSAttributedString+Attributes.h"

@implementation CodeDecorator

@synthesize name = _name;
@synthesize theme = _theme;
@synthesize extensions = _extensions;

// setup a reference type for the anonymous decoration blocks
typedef void (^DecoratorBlock)(NSTextCheckingResult*, NSMatchingFlags, BOOL*);

-(id) init
{
    self = [super init];
    
    if (self)
    {
        _name = @"PlainText";
        _extensions = [[NSArray alloc] init];
        _decorations = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

-(id) initFromDictionary:(NSDictionary *)dict andTheme:(NSMutableDictionary *)initTheme
{
    self = [super init];
    
    if (self && dict){
        _theme = initTheme;
        _name = [dict objectForKey:@"name"];
        _extensions = [dict objectForKey:@"ext"];
        _decorations = [[NSMutableArray alloc] init];
      
        NSError*                error = nil;
        NSRegularExpression*    tempRegex;
        DecoratorBlock          tempBlock;
        NSString*               tempStyleName;
        UIColor*                tempColor;
        NSDictionary*           finalUnit;
        
        NSArray *decorations = [dict objectForKey:@"decorations"];        
        for (NSDictionary* decoration in decorations)
        {
            tempRegex = [NSRegularExpression 
                                 regularExpressionWithPattern:[decoration objectForKey:@"regex"]
                                 options:0
                                 error:&error];
            
            tempStyleName   = [decoration objectForKey:@"name"];
            tempColor       = [CodeDecorator colorForHexString:[_theme objectForKey:tempStyleName]];
            
            tempBlock = ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){                
                NSRange matchRange = [match range];
                [processingAttributedString setTextColor:tempColor range:matchRange];
            };
            
            finalUnit = [NSDictionary dictionaryWithObjectsAndKeys:tempRegex,@"regex", tempBlock, @"block",nil];
            [_decorations addObject:finalUnit];
        }
    }
    
    return self;
}

-(NSAttributedString *) decorateString:(NSString *)code
{
    if (!code)
    {
        return nil;
    }
    
    return [self decorateAttributedString:[[NSAttributedString alloc] initWithString:code]];
}

-(NSAttributedString *) decorateAttributedString:(NSAttributedString *)code
{
    if (!code)
    {
        return nil;
    }
    
    NSRegularExpression *tempRegex;
    DecoratorBlock tempBlock;

    NSString *plainText = [code string];
    processingAttributedString = [code mutableCopy];
    [processingAttributedString setFont:[UIFont fontWithName:@"DroidSansMono" size:14]];
    
    for (NSDictionary* decoration in _decorations)
    {
        tempRegex = [decoration objectForKey:@"regex"];
        tempBlock = [decoration objectForKey:@"block"];
        
        [tempRegex enumerateMatchesInString:plainText options:0 range:NSMakeRange(0, [plainText length]) usingBlock:tempBlock];
    }
    
    return processingAttributedString;
}


+(UIColor *) colorForHexString:(NSString *)hexString
{
    unsigned int hex;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hex]; 
    
    CGFloat red   = ((hex & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((hex & 0x00FF00) >>  8) / 255.0f;
    CGFloat blue  =  (hex & 0x0000FF) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
}

@end
