//
//  PTTextRange.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTTextPosition.h"

// A UITextRange object represents a range of characters in a text container; in other words,
// it identifies a starting index and an ending index in string backing a text-entry object.
//
// Classes that adopt the UITextInput protocol must create custom UITextRange objects for 
// representing ranges within the text managed by the class. The starting and ending indexes 
// of the range are represented by UITextPosition objects. The text system uses both UITextRange 
// and UITextPosition objects for communicating text-layout information.

@interface PTTextRange : UITextRange

@property (nonatomic) NSRange range;

+(id)rangeWithStartPosition:(PTTextPosition *)startPosition andEndPosition:(PTTextPosition *)endPosition;

@end

