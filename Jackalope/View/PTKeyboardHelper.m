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
    UIButton *_keyboardButton;
    UIButton *_searchButton;
    
    CGRect  _fullFrame;
    CGRect  _collapsedFrame;
    BOOL    _isCollapsed;
}
@end


@implementation PTKeyboardHelper

const int h_padding = 10;
const int v_padding = 5;

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

    CGFloat height = (v_padding + MAX(_searchButton.frame.size.height, _keyboardButton.frame.size.height) + v_padding);
    _fullFrame = frame;
    _fullFrame.size.height = height;
    
    CGFloat collapsedWidth = (h_padding + _searchButton.frame.size.width + h_padding + _keyboardButton.frame.size.width + h_padding);
    CGFloat collapsedX = (frame.origin.x + frame.size.width - collapsedWidth);
    _collapsedFrame = CGRectMake(collapsedX, frame.origin.y, collapsedWidth, height);
    _isCollapsed = YES;
    
    self = [super initWithFrame:_collapsedFrame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(229.0/255.0) green:(238.0/255.0) blue:(247.0/255.0) alpha:0.9f];
        CALayer* layer = self.layer;
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:12];
        [layer setBorderWidth:0.5f];

        // show the find button
        CGRect searchFrame = CGRectMake(h_padding, v_padding, _searchButton.frame.size.width, _searchButton.frame.size.height);
        _searchButton.frame = searchFrame;
        [self addSubview:_searchButton];

        // show the keyboard button
        CGFloat hideX = searchFrame.origin.x + searchFrame.size.width + h_padding;
        CGRect hideButtonFrame = CGRectMake(hideX, v_padding, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
        _keyboardButton.frame = hideButtonFrame;
        [self addSubview:_keyboardButton];
    }
    return self;
}

-(void) searchButtonPressed:(id)sender {
    if (_isCollapsed){
        CGFloat keyboardButtonX = (_fullFrame.origin.x + _fullFrame.size.width - h_padding - _keyboardButton.frame.size.width);
        //CGRect keyboardFrame
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = _fullFrame;
//            _keyboardButton.frame.origin.x = keyboardButtonX;
        }];
        _isCollapsed = NO;
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = _collapsedFrame;
        }];
        _isCollapsed = YES;
    }
}

-(void) hideKeyboardPressed:(id)sender{
//    [self.codeView hideKeyboard];
}


@end
