//
//  TextSelectionPopupViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 11/11/12.
//
//

#import "TextSelectionPopupViewController.h"

@interface TextSelectionPopupViewController ()

@end

@implementation TextSelectionPopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    copyButton.titleLabel.text = @"Copy";
    [self.view addSubview:copyButton];
}

- (CGSize) contentSizeForViewInPopover {
    return CGSizeMake(50,30);
}

@end
