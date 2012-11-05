//
//  PTFrame.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "NSAttributedString+Attributes.h"
#import "PTTextRange.h"
#import "PTLineOfCode.h"
#import "PTCursorLayer.h"
#import "PTSelectionLayer.h"

@interface PTCodeLayer : CALayer
{
    NSMutableArray* _locArray;
    
    float _leftColumnWidth;
    float _leftGutterWidth;
    float _leftCodeOffset;
    float _lineHeight;   
    CGFloat _ascent, _descent, _leading;
    
    NSCharacterSet* _newlineCharSet;
}

// deprecated. already
- (id)initWithLinesOfCode:(NSArray *) LocArray;
- (id)initWithLinesOfCode:(NSArray*)LocArray andAttributedString:(NSAttributedString*)attributedString;

// how about this guy
// returns the range of the string that it was able to fit within the maxDisplayLines limit
-(NSInteger)loadAttributedString:(NSAttributedString*)attributedText;

@property (nonatomic)                   NSInteger       displayMode;
@property (nonatomic)                   NSInteger       startingLineNum;
@property (nonatomic)                   NSInteger       suggestedLineLimit;
@property (nonatomic, assign, readonly) NSArray*        locArray;

@property (nonatomic, retain)           PTTextRange*        selection;
@property (nonatomic, retain)           PTCursorLayer*      cursorView;
@property (nonatomic, retain)           PTSelectionLayer*   selectionLayer;

-(CFAttributedStringRef)                                copyAttributedText;
-(NSString*)                                            fullText;

-(void) updateLine:(PTLineOfCode*) line;
-(void) insertLine:(PTLineOfCode*) newLine afterLine:(PTLineOfCode*) existingLine;
-(void) removeLine:(PTLineOfCode*) line;

- (PTTextPosition *) closestPositionToPoint:(CGPoint)point;
-(void)layoutLoc:(PTLineOfCode*)loc;
-(void) updateLineHeightsBy:(NSInteger)deltaRows startingAtLine:(PTLineOfCode*) updatedLoc;

@end
