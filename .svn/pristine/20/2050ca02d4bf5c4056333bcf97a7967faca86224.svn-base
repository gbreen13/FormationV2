//
//  annotation.h
//  Formation
//
//  Created by George Breen on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfField.h"


@interface PdfAnnotation : PdfField {
	NSString *contents;
	NSString *name;
	NSString *datestring;
	UIView *elementView;

#define kANNInvisible	(1<<0)
#define kANNHidden		(1<<0)
#define kANNPrint		(1<<0)
#define kANNNoZoom		(1<<0)
#define kANNNoRotate	(1<<0)
#define kANNNoView		(1<<0)
#define kANNReadOnly	(1<<0)
#define kANNLocked		(1<<0)
#define kANNToggleNoView (1<<0)
#define kANNLockedContents (1<<0)
	int		flags;
}

; 
-(id) initWithObjno:(int)objNo andGeneration:(int)genNo andDictionary:(PdfDictionary *)fieldDictionary;
-(void) drawWithContext:(CGContextRef)ctx andPageRect:(CGRect)pageRect andRotation:(CGPDFInteger) pageRotate;
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect;
@end
