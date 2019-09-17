//
//  PdfButtonField.h
//  Formation
//
//  Created by George Breen on 2/3/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfField.h"
typedef enum {
	kPushButton,
	kRadioButton,
	kCheckButton
} ButtonType;
@interface PdfButtonField :PdfField {
	PdfReader *reader;
	ButtonType typeOfButton;
	PdfName *onState;
	PdfArray *kidsRefArray;
	int radioselected;
	NSMutableArray *kidsDictArray;		// array of Pdf Dictionaries for kids
	NSMutableArray *kidsButtons;		// all of the kinder buttons.
	UIButton *button;
}
-(id) initWithObjno:(int)objNo andGeneration:(int)genNo andDictionary:(PdfDictionary *)fd andReader:(PdfReader *)reader;
-(BOOL) isRadioButton;
-(BOOL) isButton;
-(void) setRadioButton:(NSString *)bName;
-(NSString *) getRadioButton;
-(BOOL) getNoToggleOff;
-(void) setNoToggleOff;
+(BOOL)checkForRadioButton:(PdfDictionary *)d;
-(void) setOnState;
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect;

@property ButtonType typeOfButton;
@property (nonatomic, assign) PdfName *onState;
@property (nonatomic, assign) PdfArray *kidsRefArray;
@property (nonatomic, assign) PdfReader *reader;
@property (nonatomic, assign) NSMutableArray *kidsDictArray, *kidsButtons;
@property (nonatomic, assign) UIButton *button;
@property int radioselected;
@end
