//
//  DecoratorCollection.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DecoratorCollection.h"
#import "SBJSON.h"

static DecoratorCollection *_instance = nil;

@implementation DecoratorCollection

-(void) hardcodeTheme
{
    [_defaultTheme setValue:@"0x0000FF" forKey:@"keyword"];
    [_defaultTheme setValue:@"0xC5060B" forKey:@"constant"];
    [_defaultTheme setValue:@"0x318495" forKey:@"variable"];
    [_defaultTheme setValue:@"0x036A07" forKey:@"string"];
    [_defaultTheme setValue:@"0x0000A2" forKey:@"entity"];
    [_defaultTheme setValue:@"0x6D79DE" forKey:@"support.type"];  
    [_defaultTheme setValue:@"0x6D79DE" forKey:@"support.class"];      
    [_defaultTheme setValue:@"0x06960E" forKey:@"support.constant"];  
    [_defaultTheme setValue:@"0x3C4C72" forKey:@"support.function"];    
    [_defaultTheme setValue:@"0x585CF6" forKey:@"constant.language"];    
    [_defaultTheme setValue:@"0x318495" forKey:@"variable.language"];  
}

+ (DecoratorCollection *) getInstance
{
    if (!_instance) {
        // Create the singleton
        _instance = [[super allocWithZone:NULL] init];
    }
    
    return _instance;
}

// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)init {
    
    if (_instance) {
        return _instance;
    }
    
    // create a new instance
    self = [super init];
    
    if (self)
    {
        _defaultDecorator = [[CodeDecorator alloc] init];
        
        _defaultTheme = [[NSMutableDictionary alloc] init];        
        [self hardcodeTheme];
        
        // load the JSON from bundle 
        NSString *jsonString = nil; 
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"decorations" ofType:@"json"];  
        if (filePath) {  
           jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];  
        } 
        
        SBJSON *jsonParser = [SBJSON new];
        NSArray *decorators = (NSArray *) [jsonParser objectWithString:jsonString];

        // build up a map of extensions to decorators
        // we will lazy initialize the objects only when they are requested
        if (decorators && ([decorators count] > 0))
        {
            _decoratorsForExtension = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary* decorator in decorators)
            {
                NSArray *extensions = [decorator objectForKey:@"ext"];
                for (NSString* ext in extensions){
                    [_decoratorsForExtension setValue:decorator forKey:ext];
                }
            }            
        }
    }
    
    return self;
}

-(CodeDecorator *) decoratorForFileName:(NSString *) filename{

    //TODO: parse filename and get real extension
    // For now hardcode to ruby because that's all I have ;)
    NSString *ext = [filename pathExtension];
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"OpenFile:%@",ext]];
    id decorator = [_decoratorsForExtension objectForKey:ext];
 
    if (decorator == nil)
    {
        NSLog(@"decoratorMissing:%@",ext);        
        return _defaultDecorator;
    }
    else if ([decorator isKindOfClass:[CodeDecorator class]]){
        return decorator;
    }
    else if ([decorator isKindOfClass:[NSDictionary class]]){
        CodeDecorator *newDecorator = [[CodeDecorator alloc] initFromDictionary:decorator andTheme:_defaultTheme];
        for (NSString* tempExt in [newDecorator extensions]){
            [_decoratorsForExtension setValue:newDecorator forKey:tempExt];
        }
        
        return newDecorator;
    }
    
    return nil;
}


@end
