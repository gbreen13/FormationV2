//
//  PdfField.m
//  Formation
//
//  Created by George Breen on 1/28/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfField.h"

#import "PdfName.h"
#import "PdfDictionary.h"
#import "PdfReference.h"
#import "PdfNumber.h"
#import "PdfString.h"
#import "PdfBool.h"
#import "PdfArray.h"
#import "PdfComment.h"
#import "PdfNull.h"
#import "PdfAcroForm.h"
#import "PdfPage.h"
#import "PdfTXField.h"
#import "PdfCHField.h"
#import "PdfButtonField.h"
#import "PdfReader.h"

@implementation PdfField

@synthesize objectNumber, generationNumber, fieldDictionary, original, completeFieldName, where;
@synthesize fieldName;

-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) fdict
{
	if((self = [super init]) == nil) 
		return nil;
	objectNumber = on;
	generationNumber = gen;
	fieldDictionary = fdict;
	
	PdfArray *rectArray;
	if((rectArray = [fieldDictionary objectForKey:@"/Rect"])!= nil) {
		where = [PdfReader getPdfRect:rectArray];
	}
	self.original = [self GetString];
	return self;
}
-(void) reScale: (float)scale
{
}
-(BOOL) hasChanged
{
	NSString *cur = [self toString];
	if([original isEqualToString:cur]) return FALSE;
	return TRUE;
}
	
-(NSString *)toString
{
	return [self GetString];
}

-(NSString *)GetString
{
	return [NSString stringWithFormat:@"%d %d obj\n%@\nendobj\n",objectNumber, generationNumber, [fieldDictionary toString]];
}

//
//	Gets or sets the local field name (e.g. c when complete field name is a.b.c)
//
-(void) setLocation: (CGRect) loc
{
	where = loc;
}
-(void)setName: (NSString *)s
{
	cstring *ip = [[cstring alloc]initWithString:s];
	PdfName *name = [[PdfString alloc]initWithCP:ip	andIsHex:FALSE];
	[fieldDictionary setObject: name forKey:TName];
}

-(NSString *)getName
{
	id fieldObject = [fieldDictionary objectForKey:TName];
	if(fieldObject != nil && [fieldObject isKindOfClass:[PdfString class]]) 
		return [(PdfString *)fieldObject text];
	return nil;
}
-(NSString *)getCompleteFieldName
{
	return completeFieldName;
}

-(void) setCompleteFieldName: (NSString *)s
{
	completeFieldName = s;
}

-(BOOL) getBitPosition: (int)bpo
{
	id numObject = [fieldDictionary objectForKey:FFName];
	if(numObject != nil && [numObject isKindOfClass:[PdfNumber class]]) {
		int num = [(PdfNumber *)numObject intValue];
		return ((num & (1 <<bpo)) != 0);
	}
	return  FALSE;
}

-(void) setBitPosition: (int)bpo
{
	id numObject = [fieldDictionary objectForKey:FFName];
	PdfNumber *pNum;
	int num = 0;
//
//	If the Ff field already exists, just set the bit.
	
	if(numObject != nil && [numObject isKindOfClass:[PdfNumber class]]) {
		pNum = (PdfNumber *)numObject;
		num = [pNum  intValue];
		num |= (1 <<bpo);
		pNum.number = [NSNumber numberWithInt:num];
	} else{
		num = (1 << bpo);
		NSNumber *n = [[NSNumber alloc]initWithInt:num];
		pNum = [[PdfNumber alloc] initWithNumber:n];
		[fieldDictionary setObject: pNum forKey:FFName];
	}
}

//
//	Fill in all of the fields for this form field based on the field dictionary.
//	Does not support signature fields.
//	In most cases this will return one object.  however, fields are organized according
//	to trees, where intermediate field objects may have child fields.  only terminal field objects
//	are considered "real". so this method may return more than one.
//
//	Note that fieldName can be empty, but not nil.
//
+(NSMutableArray *)GetPdfFields: (PdfReference *)reference 
					  andReader: (PdfReader *)reader 
			andParentDictionary: (PdfDictionary *)pd 
				   andFieldName:(NSString *)fname
{
	int objNo = reference.objNumber;
	int genNo = reference.generationNumber;
	PdfDictionary *fd = (PdfDictionary *)[reader GetPdfObjectFromReference:reference];
	PdfName *fn;
	NSString *fnstr = @"";
	NSMutableArray *reta = [[NSMutableArray alloc]init];
	
	if((fn = [fd objectForKey:TName])!= nil) {
		fnstr = [fn toString];
		if(![fname isEqualToString:@""])
			fname = [fname stringByAppendingString:@"."];
		fnstr = [fname stringByAppendingString:fnstr];
	}
	
//
//	If there's a parent dictionary, go through the parent dictionary and add all of the ancestrial
//	fields to this field's fieldDictoinary that have NOT been overwritten by this object already.
//
	if(pd) 
		for (id theKey in pd) 
			if([fd objectForKey:theKey] == nil) 
				[fd setObject:[pd objectForKey:theKey] forKey:theKey];
//
//	Now deal with the kids.
//	
//	It is a terminal node if there is no /Kids OR if it's a radio button (kids are the items)
//
	if(![fd objectForKey:KidsName]  || [PdfButtonField checkForRadioButton:fd]  ) {
		PdfName *fieldType = (PdfName *)[fd objectForKey:FTName];
		PdfField* field = nil;
		
		if([fieldType  isEqualToString:TXName]) {
			field = (PdfField *)[[PdfTXField alloc]initWithObjno:objNo andGeneration:genNo andDictionary:fd];
		}
		else if ([fieldType  isEqualToString:CHName]) {
			field = (PdfField *)[[PdfCHField alloc]initWithObjno:objNo andGeneration:genNo andDictionary:fd];
		}	
		
		else if ([fieldType  isEqualToString:ButtonName]) {
			field = (PdfField *)[[PdfButtonField alloc]initWithObjno:objNo andGeneration:genNo andDictionary:fd andReader:reader];
			PdfButtonField *b = (PdfButtonField *)field;
			for( PdfReference *child in [b kidsRefArray]) {
				PdfDictionary *kiddic = (PdfDictionary *)[reader GetPdfObjectFromReference: child];
				if(kiddic) {
					PdfName *typeName = [kiddic objectForKey:@"/Type"];
					if(typeName && ([typeName  isEqualToString:@"/Annot"])) {
						[reader addFormAnnotation:child formField: field];
					}
				}
			}
		} 

		else {
			NSLog(@" unsupported field type %@", [fieldType toString]);
		}
		
		if(field) {
			field.fieldName = fnstr;
			[reta addObject:field];
			//
			//	If we bottom out at this terminal object and it is an annotation type, 
			//	we need to add this reference to the reader's form annotation list.  Later
			//	When we draw the annotations we can associate that annotation with this list.
			//	Of course we only do that for fields that we can deal with.
			//
			PdfName *typeName = [fd objectForKey:@"/Type"];
			if(typeName && ([typeName  isEqualToString:@"/Annot"])) {
				[reader addFormAnnotation:reference formField: field];
			}
		}
		return reta;
	}
	
//	intermediate node.  This approach is to process all of the children and merge their dictionaries.
//	This means, if an AcroForm field references a widget annotation object, that object will be merged
//	into this field record.  This is a vaguary in the spec.  Fields can have the drawing items built into
//	them, or they can refer to other objects to represent what is drawn.
	
	else {
		PdfArray *kids = [fd objectForKey:KidsName];
		for( PdfReference *child in kids) {
//
//	Create child dictionary, copy all of the references from the parent dictionary but then remove
//	any items that are not inheritable.
//
			PdfDictionary *childDictionary = [[PdfDictionary alloc] initWithDictionary:fd];
			[childDictionary removeObjectForKey:KidsName];
			[childDictionary removeObjectForKey:TName];
			[childDictionary removeObjectForKey:AAName];
			[childDictionary removeObjectForKey:TMName];
			[childDictionary removeObjectForKey:TUName];
			[childDictionary removeObjectForKey:ParentName];
			NSMutableArray *childa = [self GetPdfFields:child andReader:reader andParentDictionary:childDictionary andFieldName:fnstr];
			[reta addObjectsFromArray:childa];
			[childa release];	// otherwise memory leak ?
		}
		return reta;
	}
}
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect
{
}
//
//	Will be replaced by individual objects.
//
-(NSMutableArray *) getUpdate
{
	if([self hasChanged]) {
#ifdef BUMPGENERATION
		generationNumber++;
#endif
		NSMutableArray *reta = [[NSMutableArray alloc]init];
		PdfReference *ref = [[PdfReference alloc]initWithNumber: [self objectNumber] andGeneration: [self generationNumber]];
		[reta addObject:ref];
		[reta addObject:[self toString]];
		return reta;
	}
	return nil;
	
}
@end
