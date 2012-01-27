//
//  DecoratorCollection.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeDecorator.h"

@interface DecoratorCollection : NSObject
{
    NSMutableDictionary*    _decoratorsForExtension;
    CodeDecorator*          _defaultDecorator;
}

+(DecoratorCollection *) getInstance;

-(CodeDecorator *) decoratorForFileName:(NSString *) filename;

@end
