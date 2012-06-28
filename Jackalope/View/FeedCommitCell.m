//
//  FileDiffCell.m
//  Jackalope
//
//  Created by Peter Terrill on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitCell.h"

CGFloat const _defaultCodeHeight = 150.f;
CGFloat const _codeXPadding = 0.f;
CGFloat const _codeBottomPadding = 10.f;

@implementation FeedCommitCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect viewFrame = CGRectMake(_codeXPadding, 0.f, self.frame.size.width-(2*_codeXPadding), (height-_codeBottomPadding));        
        _codeView = [[PTCodeScrollView alloc] initWithFrame:viewFrame];
        _codeView.isDiff = YES;
                
        self.contentMode = UIViewContentModeTopLeft;        
        [self addSubview:_codeView];

    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier cellHeight:_defaultCodeHeight];
}

-(void)setDiff:(NSString *)diff forFileName:(NSString *)fileName
{
    if (_diff != diff)
    {
        _diff = diff;

        Code* code = [[Code alloc] init];
        code.plainText = diff;
        code.fileName = fileName;
        
        _codeView.code = code;
    }
}

@end
