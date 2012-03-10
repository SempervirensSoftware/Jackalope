//
//  CommitViewController.h
//  Jackalope
//
//  Created by Peter Terrill on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobNode.h"

@interface CommitViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel    *fileName;
@property (nonatomic, retain) IBOutlet UITextView *commitMessage;

@property (nonatomic, retain) BlobNode* blobNode;

@end
