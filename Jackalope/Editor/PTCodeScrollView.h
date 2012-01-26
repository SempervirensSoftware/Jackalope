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

@interface PTCodeScrollView : UIScrollView <UIKeyInput>
{
    Code*                       _code;
    CodeDecorator*              _decorator;
    PTCursorView*               _cursorView;
    
            UIView*             _codeEditor;
    __block NSMutableArray*     _layerArray;
            PTCodeLayer*        _currentLayer;  
    
    int                         _maxFrameSize;
    
    NSCharacterSet*             _newlineCharSet;
    NSRegularExpression*        _whiteSpaceRegex;
}

@property (nonatomic, retain) PTTextRange* selection;
/* A system-provied input delegate is assigned when the system is interested in input changes. */
@property (nonatomic, assign) id <UITextInputDelegate> inputDelegate;

-(void) loadCode:(Code *)code;
-(void) insertText:(NSString *)text andMoveCursor:(BOOL)moveCursor;
-(void) setSelectionAtPoint:(CGPoint)point;
-(void) updateLayersByYOffset:(float)deltaY andLineNumOffset:(NSInteger)deltaLineNums startingAtLayer:(PTCodeLayer*) updatedLayer;

@end
