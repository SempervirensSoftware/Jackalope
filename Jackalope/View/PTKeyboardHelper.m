//
//  PTKeyboardHelper.m
//  Jackalope
//
//  Created by Peter Terrill on 12/21/12.
//
//

#import "PTKeyboardHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface PTKeyboardHelper () <UITextFieldDelegate> {
    UIButton        *_keyboardButton;
    UIButton        *_searchButton;
    UITextField     *_searchTextField;
    
    NSDictionary    *_expandedFrames;
    NSDictionary    *_collapsedFrames;
    
    BOOL            _isCollapsed;
    BOOL            _isKeyboardShown;
}
@end


@implementation PTKeyboardHelper

const int h_padding = 10;
const int v_padding = 5;
const int min_height = 35;

NSString *const kMainFrame = @"main";
NSString *const kKeyboardIconFrame = @"keyboard";

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
    CGFloat height = MAX((v_padding + MAX(_searchButton.frame.size.height, _keyboardButton.frame.size.height) + v_padding), min_height);
    CGRect fullFrame = frame;
    fullFrame.size.height = height;
    CGFloat expandedKeyboardX = (fullFrame.size.width - h_padding - _keyboardButton.frame.size.width);
    CGFloat keyboardY = ((height - _keyboardButton.frame.size.height)/2);
    CGRect expandedKeyboardFrame = CGRectMake(expandedKeyboardX, keyboardY, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
    _expandedFrames = @{kMainFrame:[NSValue valueWithCGRect:fullFrame], kKeyboardIconFrame:[NSValue valueWithCGRect:expandedKeyboardFrame]};
    
    // setup the search button
    CGFloat searchY = ((height - _searchButton.frame.size.height)/2);
    CGRect searchBtnFrame = CGRectMake(h_padding, searchY, _searchButton.frame.size.width, _searchButton.frame.size.height);
    _searchButton.frame = searchBtnFrame;
    
    //setup the search text field
    CGFloat searchFieldX = searchBtnFrame.origin.x + searchBtnFrame.size.width + h_padding;
    CGFloat searchFieldWidth = fullFrame.size.width - (searchFieldX + h_padding + _keyboardButton.frame.size.width + h_padding);
    CGRect searchFieldFrame = CGRectMake(searchFieldX, v_padding, searchFieldWidth, (fullFrame.size.height - 2*v_padding));
    _searchTextField = [[UITextField alloc] initWithFrame:searchFieldFrame];
    _searchTextField.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.f];
    _searchTextField.borderStyle = UITextBorderStyleLine;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.delegate = self;
    
    // setup up the frames for the collapsed view
    CGFloat collapsedWidth = (h_padding + _searchButton.frame.size.width + h_padding + _keyboardButton.frame.size.width + h_padding);
    CGFloat collapsedX = (frame.origin.x + frame.size.width - collapsedWidth);
    CGRect collapsedFrame = CGRectMake(collapsedX, frame.origin.y, collapsedWidth, height);
    CGFloat collapsedKeyboardX = (collapsedFrame.size.width - h_padding - _keyboardButton.frame.size.width);
    CGRect collapsedKeyboardFrame = CGRectMake(collapsedKeyboardX, keyboardY, _keyboardButton.frame.size.width, _keyboardButton.frame.size.height);
    _collapsedFrames = @{kMainFrame:[NSValue valueWithCGRect:collapsedFrame], kKeyboardIconFrame:[NSValue valueWithCGRect:collapsedKeyboardFrame]};
    _keyboardButton.frame = collapsedKeyboardFrame;
    _isCollapsed = YES;
    
    
    self = [super initWithFrame:collapsedFrame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.f];
        CALayer* layer = self.layer;
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:2];
        [layer setBorderWidth:0.4f];

        // show the search button
        [self addSubview:_searchButton];

        // show the keyboard button        
        [self addSubview:_keyboardButton];
    }

    // Monitor the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    return self;
}

-(void) searchButtonPressed:(id)sender {
    if (_isCollapsed){
        [self expand];
    } else {
        [self collapse];
    }
}

-(void) collapse {
    if ([self.delegate respondsToSelector:@selector(keyboardHelperWillCollapse:)]) {
        [self.delegate keyboardHelperWillCollapse:self];
    }
    
    CGRect viewFrame = [_collapsedFrames[kMainFrame] CGRectValue];
    CGRect keyboardFrame = [_collapsedFrames[kKeyboardIconFrame] CGRectValue];
    CGFloat currentY = self.frame.origin.y;
    viewFrame.origin.y = currentY;
    
    _isCollapsed = YES;
    
    [_searchTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = viewFrame;
        _keyboardButton.frame = keyboardFrame;
        _searchTextField.alpha = 0.f;
    } completion:^(BOOL finished) {
        if (finished){
            [_searchTextField removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(keyboardHelperDidCollapse:)]) {
                [self.delegate keyboardHelperDidCollapse:self];
            }
        }
    }];
}

-(void) expand {
    if ([self.delegate respondsToSelector:@selector(keyboardHelperWillExpand:)]) {
        [self.delegate keyboardHelperWillExpand:self];
    }
    
    CGRect viewFrame = [_expandedFrames[kMainFrame] CGRectValue];
    CGRect keyboardFrame = [_expandedFrames[kKeyboardIconFrame] CGRectValue];
    _isCollapsed = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = viewFrame;
        _keyboardButton.frame = keyboardFrame;
        _searchTextField.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (finished){
            [self addSubview:_searchTextField];
            [_searchTextField becomeFirstResponder];
        }
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([self.delegate respondsToSelector:@selector(keyboardHelperDidExpand:)]) {
        [self.delegate keyboardHelperDidExpand:self];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification *)notification
{
    // find out where the keyboard is
    NSDictionary* info = [notification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.superview convertRect:keyboardRect fromView:nil];
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, keyboardRect.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
    self.hidden = NO;
}

-(void) keyboardWillHide:(NSNotification *)notification{
    self.hidden = YES;
}

-(void) hideKeyboardPressed:(id)sender{
    [self endEditing:YES];
    [self.delegate keyboardHelperHideKeyboard:self];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSString *searchText = textField.text;
    BOOL textFound = [self.delegate keyboardHelper:self searchForString:searchText];
    return NO;
}


@end
