//
//  CodeDiffViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Code.h"
#import "PTCodeScrollView.h"

@interface CodeDiffViewController : UIViewController
{
    Code* _code;
    PTCodeScrollView* _codeView;
}

@property (nonatomic, retain) Code* code;

-(id) initWithCode:(Code*)code;

@end
