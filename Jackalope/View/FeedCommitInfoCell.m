//
//  FeedCommitInfo.m
//  Jackalope
//
//  Created by Peter Terrill on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitInfoCell.h"

CGFloat const _commitInfoXPadding = 10.f;
CGFloat const _commitInfoYPadding = 10.f;

@implementation FeedCommitInfoCell

@synthesize commit = _commit;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {        
        CGRect tempFrame;
        tempFrame = CGRectMake(_commitInfoXPadding, _commitInfoYPadding, (self.bounds.size.width-(2*_commitInfoXPadding)), 18);
        _userLabel = [[UILabel alloc] initWithFrame:tempFrame];        
        _userLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];        
        [self addSubview:_userLabel];

        tempFrame.origin.x += 5;
        tempFrame.origin.y += (_userLabel.frame.size.height + 2);
        tempFrame.size.height = 14;
        _dateLabel = [[UILabel alloc] initWithFrame:tempFrame];        
        _dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        [self addSubview:_dateLabel];
        
        tempFrame.origin.y += (_dateLabel.frame.size.height + 6);
        tempFrame.size.height = 16;
        _messageLabel = [[UILabel alloc] initWithFrame:tempFrame];        
        _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [self addSubview:_messageLabel];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yy hh:mm a"];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

-(void) setCommit:(Commit *)commit
{
    if (commit != _commit)
    {
        _commit = commit;
        [self refresh];
    }
}

-(void) refresh
{
    if (_commit){
        if (_commit.authorName) {
            _userLabel.text = _commit.authorName;
        }
        if (_commit.date) {
            _dateLabel.text = [_dateFormatter stringFromDate:_commit.date];
        }
        if (_commit.message){
            _messageLabel.text = _commit.message;
        }
    }
}

@end