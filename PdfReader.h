//
//  PdfReader.h
//  Formation
//
//  Created by George Breen on 1/28/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"
#import "cstring.h"
#import "PdfName.h"
#import "PdfBool.h"
#import "PdfString.h"
#import "PdfReference.h"
#import "PdfDictionary.h"
#import "PdfReference.h"
#import "PdfArray.h"
#import "PdfNumber.h"

#import "PdfField.h"
#import "PdfAcroForm.h"
#import "PdfPageTreeNode.h"
#import "PdfPage.h"

#import "XrefEntry.h"


@class cstring;
@class PdfDictionary;
@interface PdfReader : NSObject {
// File info
	NSURL	*filePath;
	NSFileHandle *fd;
	BOOL	isLinearized;
	int		nullOffset;
	int		previous;
	unsigned long	curposition;
	unsigned long	originalSize;
	int	lastObject;
	int endOfFile;
	BOOL	newTrailerFormat;
	
	//	xref table/object  info
	
	NSMutableDictionary *objectTable;		// entries keyed by object number
	NSMutableArray *offsetTable;			// keys sorted
	int rootObjectNumber;					// object of Document array
	int rootGeneration;
	NSData *pdf;							// read the whole PDF file into here for parsing.
	NSMutableData *changes;						// update changes

	//	trailer info
	
	NSString *trailerString;				// used to store the trailer for outputing the file
	PdfDictionary	*previousTrailer;

	//	Acro form info
	
	PdfAcroForm *form;						// For structure for AcroForm if found
	NSMutableArray *fields;					// Array for storing all of the form fields.
	NSMutableDictionary *fieldsByName;		// dictionary keyed by a unique assigned name

	//	Page info
	
	int curPage;							// page number
	int totalPages;							// total number of pages in document
	PdfPage *page;							// Page object
	PdfReference *PdfPageRef;				// pulled from document catalog.
	PdfPageTreeNode *pageTreeNode;
	NSMutableArray *allPageObjects;			// array with each page in order.
	CGPDFPageRef myPageRef;
	
//	CGPDF structures for drawing the regular page.

    CGPDFDocumentRef myDocumentRef;
 	NSMutableDictionary *formAnnotations;		// used for drawing forms.  key = annotation objecy number, value = PdfField.
	
}

@property (nonatomic, copy) NSURL *filePath;
@property (nonatomic, assign) NSFileHandle *fd;
@property (nonatomic, assign) NSMutableDictionary *objectTable;
@property (nonatomic, assign) NSMutableArray *offsetTable;
@property (nonatomic, copy) NSString *trailerString;
@property (nonatomic, assign) NSMutableArray *annotations;
@property (nonatomic, assign) PdfPage *page;
@property (nonatomic, assign) cstring *PDFInput;
@property (nonatomic, assign) PdfAcroForm *form;
@property (nonatomic, assign) NSMutableArray *fields;
@property (nonatomic, assign) NSMutableDictionary *fieldsByName, *formAnnotations;
@property (nonatomic, retain) NSData *pdf, *changes;
@property CGPDFDocumentRef myDocumentRef;
@property CGPDFPageRef myPageRef;
@property int previous, rootObjectNumber, rootGeneration;
@property int curPage, endOfFile, totalPages;
@property (nonatomic, assign) NSMutableArray *allPageObjects;
@property (nonatomic, assign) PdfPageTreeNode *pageTreeNode;
@property BOOL newTrailerFormat;

-(BOOL) loadFileWithURL: (NSURL *)url error:(NSError **)error;
-(BOOL) Parse:(NSError **)error;
-(PdfObject *)GetPdfObjectFromNumber: (int)number;
-(PdfObject *) GetPdfObjectFromReference: (PdfReference *)ref;
-(int) GetEndOfObject:(int)objNumber;
-(XrefEntry *)GetPdfXrefEntryFromNumber: (int)number;
-(void) ParseAcroForm;
-(void) ParsePageTree;
-(NSString *)	dumpTable;
-(void) ParseXRef: (cstring *)input from: (int) startxref;
-(PdfObject *)ParseObjectInCstring:(cstring *)objInput;
-(PdfObject *) ParseObjectFromHere: (int) start toHere: (int)end;
-(void) addFormAnnotation:(PdfReference *)ref formField:(PdfField *)field;
-(id) GetFormAnnotation: (int) objno;
-(PdfPage *) PdfGetPageObject: (int) page;
-(PdfReference *)CreateNewReference;
-(NSString *)CreateDFDData;
-(PdfDictionary *)ParseDFDData:(NSString *)dfd;
-(BOOL) UpdateAllChanges;
-(void) ReplaceTextFields:(NSString *)dfd;


-(int) GetPreviousStartXREF: (cstring *)ip fromEnd: (int) end;
-(void) ReadDFDFile:(NSURL *)filepath;
-(void) WriteDFDFile: (NSURL *)filepath;
-(void) WritePdf:(NSURL *) url;
-(void) ParseAcroForm;
-(NSString *)GetTrailer: (int)offset;
+(CGRect) getPDFRect:(CGPDFArrayRef) rectArray;
+(CGRect) getPdfRect:(PdfArray *) rectArray;
-(UIFont *)getPdfFont:(PdfDictionary *)d;
-(void) loadPage: (int) pageNo withView: (UIView *)view;
-(void) drawWithContext:(CGContextRef)ctx;
-(void) addPageObject: (PdfPage *)p;
-(void) saveChanges;
-(void) unloadFile;
@end

extern PdfReader *sharedPdfReader;
