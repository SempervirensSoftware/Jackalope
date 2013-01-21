//
//  PTKeyboardHelper.h
//  Jackalope
//
//  Created by Peter Terrill on 12/21/12.
//
//

#import <UIKit/UIKit.h>
@protocol KeyboardHelperDelegate;

@interface PTKeyboardHelper : UIView
    @property (nonatomic, retain) id<KeyboardHelperDelegate> delegate;
@end

@protocol KeyboardHelperDelegate <NSObject>

-(BOOL)keyboardHelper:(PTKeyboardHelper*)helper searchForString:(NSString*)searchString;

@optional

-(void)keyboardHelperWillExpand:(PTKeyboardHelper*)helper;
-(void)keyboardHelperDidExpand:(PTKeyboardHelper*)helper;

-(void)keyboardHelperWillCollapse:(PTKeyboardHelper*)helper;
-(void)keyboardHelperDidCollapse:(PTKeyboardHelper*)helper;

-(void)keyboardHelperHideKeyboard:(PTKeyboardHelper*)helper;

@end