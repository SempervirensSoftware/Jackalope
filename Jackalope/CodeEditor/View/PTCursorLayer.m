//
//  PTCursorView.m
//  EditorSandbox
//
//  Created by Peter Terrill on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTCursorLayer.h"

@implementation PTCursorLayer

static const NSTimeInterval InitialBlinkDelay = 0.7;
static const NSTimeInterval BlinkRate = 0.5;

-(void) commonInit{
    self.backgroundColor = [[UIColor blackColor] CGColor];
    [self removeAllAnimations];
}

-(id)init{
    self = [super init];
    if (self) { [self commonInit];}
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    if ((self = [super init])) {
        [self commonInit];
        self.frame = frame;
    }    
    return self;
}

// Helper method to toggle hidden state of caret view
- (void)blink
{
    self.hidden = !self.hidden;
}

// UIView didMoveToSuperview override to set up blink timers after caret view created in superview
- (void)startBlinking
{
    self.hidden = NO;    
    _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:BlinkRate target:self selector:@selector(blink) userInfo:nil repeats:YES];
    [self delayBlink];
}

-(void)stopBlinking
{
    [_blinkTimer invalidate];
    _blinkTimer = nil;        
}

// Helper method to set an initial blink delay
- (void)delayBlink
{
    self.hidden = NO;    
    [_blinkTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:InitialBlinkDelay]];
}


- (id<CAAction>)actionForKey:(NSString *)event
{
    CATransition *theAnimation=nil;
    if ([event isEqualToString:@"position"])
    {
        theAnimation = [CAAnimation animation];
        theAnimation.duration = 0.1;
    }    
    
    return theAnimation;
}

- (void)dealloc
{
    [_blinkTimer invalidate];
}


@end

