//
//  FeedCommitSectionHeader.h
//  Jackalope
//
//  Created by Peter Terrill on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedCommitSectionHeaderDelegate;

@interface FeedCommitSectionHeader : UIView

@property (nonatomic, readonly, weak)   UILabel     *titleLabel;
@property (nonatomic, weak)             UIButton    *disclosureButton;
@property (nonatomic, assign)           NSInteger   section;
@property (nonatomic, retain)           id <FeedCommitSectionHeaderDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title section:(NSInteger)sectionNumber delegate:(id <FeedCommitSectionHeaderDelegate>)delegate;

@end


// Protocol to notify the table view controller of header taps
@protocol FeedCommitSectionHeaderDelegate <NSObject>

-(void)fileSectionOpened:(NSInteger)section;
-(void)fileSectionClosed:(NSInteger)section;

@end
