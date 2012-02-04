//
//  DetailViewController.h
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobNode.h"
#import "PTCodeScrollView.h"

@interface CodeViewController : UIViewController <UISplitViewControllerDelegate>
{
    BlobNode*   _blobNode;
}

@property (nonatomic, retain) IBOutlet PTCodeScrollView* codeView;

-(void) showBlobNode:(BlobNode *)blob;
-(void) showLoadingWithTitle:(NSString *)titleString;
-(void) showErrorWithTitle:(NSString *)titleString andMessage:(NSString *) message;

@end
