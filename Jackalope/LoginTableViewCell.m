//
//  LoginTableViewCell.m
//  Jackalope
//
//  Created by Peter Terrill on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginTableViewCell.h"

@implementation LoginTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[UITextField alloc] init];
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.backgroundColor = [UIColor clearColor];
        
        [[self contentView] addSubview:_textField];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(NSString *) getFieldText
{
    return _textField.text;
}

-(void) setFieldType:(NSString *)LOGIN_CELL_TYPE
{
    if (LOGIN_CELL_TYPE == LOGIN_CELL_EMAIL){
        _textField.placeholder = @"Email";
        _textField.secureTextEntry = NO;
    }
    else if (LOGIN_CELL_TYPE == LOGIN_CELL_PASSWORD) {
        _textField.placeholder = @"Password";
        _textField.secureTextEntry = YES;
    }
}

-(void) setFocus
{
    [_textField becomeFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // How much space do we have to work with?
    CGRect bounds = [[self contentView] bounds];
    float cellHeight = bounds.size.height;
    float cellWidth = bounds.size.width;
    float inset = 5.0;
    
    CGRect textFieldFrame = CGRectMake(inset, 10, (cellWidth-2*inset), cellHeight);
    [_textField setFrame:textFieldFrame];
}


NSString *const LOGIN_CELL_EMAIL = @"email";
NSString *const LOGIN_CELL_PASSWORD = @"password";


@end
