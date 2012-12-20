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
        
    UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 60, 20)];
    [copyButton setTitle:@"Copy" forState:UIControlStateNormal];
    [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyText:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:copyButton];
}

- (void) copyText:(id)sender {
    NSLog(@"Copy Text:");
}

- (CGSize) contentSizeForViewInPopover {
    return CGSizeMake(70,30);
}

@end
