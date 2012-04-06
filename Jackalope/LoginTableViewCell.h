//
//  LoginTableViewCell.h
//  Jackalope
//
//  Created by Peter Terrill on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewCell : UITableViewCell{
    UITextField* _textField;
}

-(NSString *) getFieldText;

-(void) setFieldType:(NSString *)LOGIN_CELL_TYPE;
-(void) setFocus;


extern NSString *const LOGIN_CELL_EMAIL;
extern NSString *const LOGIN_CELL_PASSWORD;

@end
