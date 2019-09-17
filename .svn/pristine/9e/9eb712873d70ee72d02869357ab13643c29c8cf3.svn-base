//
//  PdfField.h
//  Formation
//
//  Created by George Breen on 1/28/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"
//
//	valid field names
//
#define APName		@"/AP"
#define NName		@"/N"
#define	VName		@"/V"
#define TName		@"/T"
#define FFName		@"/Ff"
#define FTName		@"/FT"
#define TXName		@"/Tx"
#define CHName		@"/Ch"
#define ButtonName	@"/Btn"
#define KidsName	@"/Kids"
#define	AAName		@"/AA"
#define	TMName		@"/TM"
#define TUName		@"/TU"
#define ParentName	@"/Parent"
#define IName		@"/I"
#define ASName		@"/AS"

@class PdfAcroForm;
@class PdfPage;
@class PdfTXField;
@class PdfCHField;
@class PdfReader;

@interface PdfField : NSObject {
	int	objectNumber;
	int generationNumber;
	PdfDictionary *fieldDictionary;
	CGRect where;
	NSString *fieldName;
	NSString *completeFieldName;		// Completely inherited field name (e.g. a.b.c)
	NSString *original;					// the original fields as generated with toString.
}

@property int objectNumber;
@property int generationNumber;
@property (nonatomic, assign) PdfDictionary *fieldDictionary;
@property (nonatomic, copy) NSString *original, *completeFieldName, *fieldName;
@property CGRect where;

-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) fdict;
+(NSMutableArray *)GetPdfFields: (PdfReference *)reference andReader: (PdfReader *)reader andParentDictionary: (PdfDictionary *)pd andFieldName:(NSString *)fname;
-(BOOL) hasChanged;
-(NSString *)GetString;
-(NSString *)toString;
-(void)setName: (NSString *)s;
-(NSString *)getName;
-(NSString *)getCompleteFieldName;
-(void) setCompleteFieldName: (NSString *)s;
-(BOOL) getBitPosition: (int)bpo;
-(void) setBitPosition:(int)bpo;
-(void) setLocation: (CGRect) loc;
-(NSMutableArray *) getUpdate;
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect;
-(void) reScale: (float)scale;

@end
