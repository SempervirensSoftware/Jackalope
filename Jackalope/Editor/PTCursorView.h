//
//  PTCursorView.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PTCursorView : CALayer
{
    NSTimer *_blinkTimer;
}

-(void)startBlinking;
-(void)stopBlinking;
-(void)delayBlink;

@end
