//
//  AcroForm.m
//  Formation
//
//  Created by George Breen on 1/19/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfAcroForm.h"
#import "PdfObject.h"
#import "PdfArray.h"
#import "PdfReference.h"
#import "PdfReader.h"
#import "PdfBool.h"

@implementation PdfAcroForm


-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) formDictionary
{
	self = [super initWithObjno:  on andGeneration:  gen andDictionary: (PdfDictionary *) formDictionary];
	if(self == nil) return nil;
//
//	We've seen erroneous repeated objects in this array and the Annots arry in pages.  remove them.
//
	PdfObject *fieldsObject = [fieldDictionary objectForKey:@"/Fields"];
	PdfArray *fieldArray;
	
	if ([fieldsObject isKindOfClass:[PdfArray class]]) 
		fieldArray = (PdfArray *)fieldsObject;	// array
	
	else if ([fieldsObject isKindOfClass:[PdfReference class]])
		fieldArray = (PdfArray *)[sharedPdfReader GetPdfObjectFromReference:(PdfReference *)fieldsObject]; //reference
	
	[fieldArray removeRedundancies];
	
//	PdfBool *nval = [[PdfBool alloc] initWithVal:TRUE];
//	[fieldDictionary setObject:nval forKey:NAName];
	return self;
}
	
		
@end
