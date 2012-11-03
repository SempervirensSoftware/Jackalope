//
//  FeedCommitSectionHeader.m
//  Jackalope
//
//  Created by Peter Terrill on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitSectionHeader.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const _disclosureWidth = 35.f;
CGFloat const _commitHeaderXPadding = 20.f;

@implementation FeedCommitSectionHeader

@synthesize titleLabel = _titleLabel;
@synthesize disclosureButton = _disclosureButton;
@synthesize section = _section;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber delegate:(id <FeedCommitSectionHeaderDelegate>)delegate {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        // Set up the tap gesture recognizer.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSection:)];
        [self addGestureRecognizer:tapGesture];
        
        _delegate = delegate;        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        // Create and configure the title label.
        _section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += _disclosureWidth;
        titleLabelFrame.size.width -= (_disclosureWidth + _commitHeaderXPadding);
        UILabel *label = [[UILabel alloc] initWithFrame:titleLabelFrame];
        label.text = title;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = UILineBreakModeHeadTruncation;
        [self addSubview:label];
        _titleLabel = label;        
        
        // Create and configure the disclosure button.
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 2.0, _disclosureWidth, 35.0);
        button.selected = NO;
        [button setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"carat-open.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(toggleSection:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _disclosureButton = button;        
    }
    
    return self;
}

-(void)toggleSection:(id)sender {
    
    // Toggle the disclosure button state.
    self.disclosureButton.selected = !self.disclosureButton.selected;

    if (self.disclosureButton.selected) {
        [self.delegate fileSectionOpened:self.section];
    }
    else {
        [self.delegate fileSectionClosed:self.section];
    }
    
}


@end
