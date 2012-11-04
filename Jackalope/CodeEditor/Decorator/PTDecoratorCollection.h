//
//  DecoratorCollection.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTCodeDecorator.h"

@interface PTDecoratorCollection : NSObject
{
    NSMutableDictionary*    _decoratorsForExtension;
    NSMutableDictionary*    _defaultTheme;
    PTCodeDecorator*          _defaultDecorator;
}

+(PTDecoratorCollection *) getInstance;

-(PTCodeDecorator *) decoratorForFileName:(NSString *) filename;

@end
