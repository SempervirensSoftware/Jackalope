//
//  PTCodeScrollView.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecoratorCollection.h"
#import "Code.h"
#import "PTCodeLayer.h"
#import "PTCursorView.h"

@protocol PTCodeViewDelegate <UITextInputDelegate>

@optional

-(void) keyboardDidShow:(NSNotification*)notification;
-(void) keyboardWillHide:(NSNotification*)notification;

@end

@interface PTCodeScrollView : UIScrollView <UITextInput, UIScrollViewDelegate>
{
    CodeDecorator*              _decorator;
    PTCursorView*               _cursorView;
    CGRect                      _keyboardRect;
    
            UIView*             _codeEditor;
    __block NSMutableArray*     _layerArray;
            PTCodeLayer*        _currentLayer;  
        
    NSCharacterSet*             _newlineCharSet;
    NSRegularExpression*        _whiteSpaceRegex;
    
    NSOperationQueue*           _operationQueue; // for rendering layers on a seperate thread
    NSMutableArray*             _codeViewDelegates; // want to be able to notify multiple delegates not just the system
    
    // Display scaling factors
    // Tune these for ideal performance and appearance.
    int                         _maxFrameSize;
    int                         _numberOfScreensToBuffer;
    int                         _numberOfExtraScrollLines;

}

@property (nonatomic, retain)   PTTextRange*  selection;
@property (nonatomic, retain)   Code*         code;
@property (nonatomic)           BOOL          isDiff;

-(void) insertText:(NSString *)text andMoveCursor:(BOOL)moveCursor;
-(void) setSelectionAtPoint:(CGPoint)point;
-(void) scrollToCursor;
-(void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAfterLayer:(PTCodeLayer*) updatedLayer;

-(void) showKeyboard;
-(void) hideKeyboard;
-(void) addCodeViewDelegate:(id <PTCodeViewDelegate>)delegate;
-(void) removeCodeViewDelegate:(id <PTCodeViewDelegate>)delegate;

#pragma mark UITextInput properties

/* If text can be selected, it can be marked. Marked text represents provisionally
 * inserted text that has yet to be confirmed by the user.  It requires unique visual
 * treatment in its display.  If there is any marked text, the selection, whether a
 * caret or an extended range, always resides witihin.
 * Setting marked text either replaces the existing marked text or, if none is present,
 * inserts it from the current selection. */ 
@property (nonatomic, assign, readonly) UITextRange *markedTextRange;                       // Nil if no marked text.
@property (nonatomic, copy) NSDictionary *markedTextStyle;                          // Describes how the marked text should be drawn.

/* Text may have a selection, either zero-length (a caret) or ranged.  Editing operations are
 * always performed on the text from this selection.  nil corresponds to no selection. */
@property (readwrite, copy) UITextRange *selectedTextRange;

/* The end and beginning of the the text document. */
@property (nonatomic, assign, readonly) UITextPosition *beginningOfDocument;
@property (nonatomic, assign, readonly) UITextPosition *endOfDocument;

/* A system-provied input delegate is assigned when the system is interested in input changes. */
@property (nonatomic, assign) id <UITextInputDelegate> inputDelegate;

/* A tokenizer must be provided to inform the text input system about text units of varying granularity. */
@property (nonatomic, assign, readonly) id <UITextInputTokenizer> tokenizer;



@end
