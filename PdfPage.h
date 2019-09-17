//
//  PdfPage.h
//  Formation
//
//  Created by George Breen on 1/19/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PdfReader.h"


@interface PdfPage : NSObject <UIScrollViewDelegate> {
	int objectNumber;
	int generationNumber;
	PdfDictionary *pageDictionary;
	
	PdfReader *reader;
	
	CGPDFPageRef	cGPDFpageRef;
	UIView *myContentView;
    UIScrollView *scrollView;
	
	CGPDFDictionaryRef cGPDGpageDictionary;	
	NSString *original;
	PdfDictionary *parent;
	CGRect	MediaBox;
	CGRect	CropBox;
	CGRect	BleedBox;
	CGRect	TrimBox;
	CGRect	ArtBox;

	PdfDictionary *BoxColorInfo;
	int		Rotate;
	PdfDictionary *Group;
	
	NSMutableArray *Annots;		// This page's active list of annotations and form fields.
    NSMutableArray *ChangedAnnots;
    NSMutableArray *NewAnnots;
	PdfArray *AnnotsRefArray;
	
}

@property (nonatomic, assign) NSMutableArray *Annots, *ChangedAnnots, *NewAnnots;
@property CGPDFPageRef cGPDFpageRef;
@property CGPDFDictionaryRef cGPDGpageDictionary;
@property (nonatomic, assign) PdfDictionary *Group, *pageDictionary;
@property int objectNumber, generationNumber;
@property (nonatomic, assign) PdfArray *AnnotsRefArray;
@property (nonatomic, assign) PdfReader *reader;
@property (nonatomic, assign) UIView *myContentView;
@property (nonatomic, assign) UIScrollView *scrollview;
@property (nonatomic, copy) NSString *original;
		   

-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) fdict andReader: (PdfReader*)r;
-(NSString *)toString;
-(BOOL) hasChanged;
-(NSString *)GetString;
-(NSMutableArray *)GetNewAnnots;
-(NSMutableArray *)GetChangedAnnots;

-(void) drawWithContext: (CGContextRef) ctx;
-(void) PdfPageLoadPage:(CGPDFPageRef)page withView:(UIView *)view;
-(void) PdfPageUnloadPage;
-(void) loadAnnots;
@end
