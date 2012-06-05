//
//  FeedCommitView.m
//  Jackalope
//
//  Created by Peter Terrill on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitView.h"

@implementation FeedCommitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect messageFrame = self.bounds;
        
        messageFrame.origin.x = (messageFrame.origin.x + 10);
        messageFrame.origin.y = (messageFrame.origin.y + 20);
        messageFrame.size.width = (messageFrame.size.width - 20);
        messageFrame.size.height = 30;
        UITextView* commitMessage = [[UITextView alloc] initWithFrame:messageFrame];
        commitMessage.editable = false;
        [self addSubview:commitMessage];
                
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
