//
//  LineOfCode.h
//  EditorSandbox
//
//  Created by Peter Terrill on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface PTLineOfCode : NSObject

@property(nonatomic) CFAttributedStringRef  attributedText;
@property(nonatomic) NSInteger              startIndexAtTypesetting;

@property(nonatomic) NSInteger  lineNum;
@property(nonatomic) NSInteger  numDisplayLines;
@property(nonatomic) CFTypeRef  lineRef;
@property(nonatomic) CGRect     displayRect;

@property(nonatomic) BOOL needsLayout;
@property(nonatomic) BOOL needsRedraw;

-(id) initWithAttributedString:(CFAttributedStringRef)text;
-(id) initWithAttributedString:(CFAttributedStringRef)text typsetterOffset:(NSInteger)offset andLine:(CTLineRef)line;
-(id) initWithAttributedString:(CFAttributedStringRef)text typsetterOffset:(NSInteger)offset andLineArray:(CFArrayRef)array;

@end
