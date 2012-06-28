//
//  FileDiffCell.h
//  Jackalope
//
//  Created by Peter Terrill on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTCodeScrollView.h"

@interface FeedCommitCell : UITableViewCell
{
    PTCodeScrollView*   _codeView;
    NSString*           _diff;
    NSString*           _fileName;    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellHeight:(CGFloat)height;

- (void) setDiff:(NSString *)diff forFileName:(NSString *)fileName;

@end
