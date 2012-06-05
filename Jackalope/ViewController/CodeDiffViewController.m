//
//  CodeDiffViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CodeDiffViewController.h"

@implementation CodeDiffViewController

-(id) initWithCode:(Code *)code
{
    self = [super init];
    if (self)
    {
        CGRect frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
        _codeView = [[PTCodeScrollView alloc] initWithFrame:frame];
        _codeView.code = code;
        [self.view addSubview:_codeView];
    }
    return self;
}

-(Code*) code
{
    return _code;
}
-(void) setCode:(Code *)code
{
    if (code != _code)
    {
        _code = code;
        _codeView.code = code;
    }
}

@end
