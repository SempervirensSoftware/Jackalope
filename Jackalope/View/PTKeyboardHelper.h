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
@optional

-(void)keyboardHelperWillExpand:(PTKeyboardHelper*)helper;
-(void)keyboardHelperDidExpand:(PTKeyboardHelper*)helper;

-(void)keyboardHelperWillCollapse:(PTKeyboardHelper*)helper;
-(void)keyboardHelperDidCollapse:(PTKeyboardHelper*)helper;

-(void)keyboardHelperHideKeyboard:(PTKeyboardHelper*)helper;
-(void)keyboardHelper:(PTKeyboardHelper*)helper SearchForString:(NSString*)searchString;

@end

