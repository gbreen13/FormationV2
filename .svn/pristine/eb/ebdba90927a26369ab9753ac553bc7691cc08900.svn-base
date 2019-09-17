//
//  PdfTXField.h
//  Formation
//
//  Created by George Breen on 1/30/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfField.h"
#import "PdfObject.h"
#import "PdfDictionary.h"

@interface BCZeroEdgeTextView : UITextView
@end


@interface PdfTXField : PdfField <UITextViewDelegate, UITextFieldDelegate> {
	UIFont *textFont;
	UITextField *textField;		// either UITextField or UITextView for multi line.
	BCZeroEdgeTextView *textView;		// either UITextField or UITextView for multi line.

}

@property (nonatomic, assign)  BCZeroEdgeTextView* textView;
@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, assign) UIFont *textFont;

-(id) initWithObjno:(int)objNo andGeneration:(int)genNo andDictionary:(PdfDictionary *)fieldDictionary;
-(NSString *)getText;
-(void) setText:(NSString *)value;
-(BOOL) isMultiLineBit;
-(void) setMultiLineBit;
-(BOOL) isPasswordBit;
-(void) setPasswordBit;
-(BOOL) isFileSelectBit;
-(void) setFileSelectBit;
-(BOOL) isDoNotScrollBit;
-(void) setDoNotScrollBit;
-(BOOL) isDoNotSpellCheckBit;
-(void) setDoNotSpellCheckBit;
-(void) drawWithContext:(CGContextRef)ctx andPageRect:(CGRect)pageRect andRotation:(CGPDFInteger) pageRotate;
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect;
-(void) reScale: (float)scale;
@end
