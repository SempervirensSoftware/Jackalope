//
//  PTKeyboardHelper.m
//  Jackalope
//
//  Created by Peter Terrill on 12/21/12.
//
//

#import "PTKeyboardHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface PTKeyboardHelper (){
    UIButton        *_keyboardButton;
    UIButton        *_searchButton;
    UITextField     *_searchTextField;
    
    NSDictionary    *_expandedFrames;
    NSDictionary    *_collapsedFrames;
    
    BOOL            _isCollapsed;
}
@end


@implementation PTKeyboardHelper

const int h_padding = 10;
const int v_padding = 5;

NSString *const kMainFrame = @"main";
NSString *const kKeyboardFrame = @"keyboard";

- (id)initWithFrame:(CGRect)frame
{
    _keyboardButton = [[UIButton alloc] init];
    [_keyboardButton setImage:[UIImage imageNamed:@"glyphicons_268_keyboard_wireless"] forState:UIControlStateNormal];
    [_keyboardButton addTarget:self action:@selector(hideKeyboardPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardButton sizeToFit];
    
    _searchButton = [[UIButton alloc] init];
    [_searchButton setImage:[UIImage imageNamed:@"01-magnify.png"] forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_searchButton sizeToFit];

    // setup the frames for the expanded view
    CGFloat height = (v_padding + MAX(_searchButton.frame.size.height, _keyboardButton.frame.size.height) + v_padding);
    CGRect fullFrame = frame;
    fullFrame.size.height = height;
    CGFloat expandedKeyboardX = (fullFrame.size.width - h_padding - _keyboardButton.frame.size.width);
    CGRect expandedKeyboardFrame = CGRectMake(expandedKeyboardX, v_padding, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
    _expandedFrames = @{kMainFrame:[NSValue valueWithCGRect:fullFrame], kKeyboardFrame:[NSValue valueWithCGRect:expandedKeyboardFrame]};
    
    // setup the search button frame
    CGRect searchFrame = CGRectMake(h_padding, v_padding, _searchButton.frame.size.width, _searchButton.frame.size.height);
    _searchButton.frame = searchFrame;
    
    // setup up the frames for the collapsed view
    CGFloat collapsedWidth = (h_padding + _searchButton.frame.size.width + h_padding + _keyboardButton.frame.size.width + h_padding);
    CGFloat collapsedX = (frame.origin.x + frame.size.width - collapsedWidth);
    CGRect collapsedFrame = CGRectMake(collapsedX, frame.origin.y, collapsedWidth, height);
    CGFloat collapsedKeyboardX = (collapsedFrame.size.width - h_padding - _keyboardButton.frame.size.width);
    CGRect collapsedKeyboardFrame = CGRectMake(collapsedKeyboardX, v_padding, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
    _collapsedFrames = @{kMainFrame:[NSValue valueWithCGRect:collapsedFrame], kKeyboardFrame:[NSValue valueWithCGRect:collapsedKeyboardFrame]};
    _keyboardButton.frame = collapsedKeyboardFrame;
    _isCollapsed = YES;
    
    self = [super initWithFrame:collapsedFrame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.f];
        CALayer* layer = self.layer;
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:8];
        [layer setBorderWidth:0.5f];

        // show the search button
        [self addSubview:_searchButton];

        // show the keyboard button        
        [self addSubview:_keyboardButton];
    }
    return self;
}

-(void) searchButtonPressed:(id)sender {
    if (_isCollapsed){
        CGRect viewFrame = [_expandedFrames[kMainFrame] CGRectValue];
        CGRect keyboardFrame = [_expandedFrames[kKeyboardFrame] CGRectValue];
        _isCollapsed = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = viewFrame;
            _keyboardButton.frame = keyboardFrame;
        }];
    } else {
        CGRect viewFrame = [_collapsedFrames[kMainFrame] CGRectValue];
        CGRect keyboardFrame = [_collapsedFrames[kKeyboardFrame] CGRectValue];
        _isCollapsed = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = viewFrame;
            _keyboardButton.frame = keyboardFrame;
        } completion:^(BOOL finished) {
            if (finished){
                
            }
        }];
    }
}

-(void) hideKeyboardPressed:(id)sender{
//    [self.codeView hideKeyboard];
}


@end
