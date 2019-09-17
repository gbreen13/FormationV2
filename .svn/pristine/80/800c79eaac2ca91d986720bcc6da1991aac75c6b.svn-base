//
//  PdfCHField.m
//  Formation
//
//  Created by George Breen on 1/30/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfCHField.h"
#import "PdfObject.h"
#import "PdfNull.h"
#import "PdfNumber.h"
#import "PdfDictionary.h"
#import "PdfArray.h"


@implementation PdfCHField
-(id) initWithObjno:(int)objNo andGeneration:(int)genNo andDictionary:(PdfDictionary *)fd
{
	return ([super initWithObjno:objNo andGeneration:genNo andDictionary:fd]) ;
}
-(BOOL) isComboBit
{
	return [self getBitPosition:18];
}
-(void) setComboBit
{
	[self setBitPosition:18];
}
-(BOOL) isEditBit
{
	return [self getBitPosition:19];
}
-(void) setEditBit
{
	[self setBitPosition:19];
}
-(BOOL) isSortBit
{
	return [self getBitPosition:20];
}
-(void) setSortBit
{
	[self setBitPosition:20];
}
-(BOOL) isMultiSelectBit
{
	return [self getBitPosition:22];
}
-(void) setMultiSelectBit
{
	[self setBitPosition:22];
}
-(BOOL) isDoNotSpellCheckBit
{
	return [self getBitPosition:23];
}
-(void) setDoNotSpellCheckBit
{
	[self setBitPosition:23];
}
//
//	Sets the list of indices that are to be set in this object.
//	if none, set it to PdfNull
//	in only one number in the list, set it to a PdfNumber for this
//	if several numbers, create a PdfArray of PdfNumbers and set to that.
//	Array of NSnumbers with showing the indices that are seleced.
//
-(void) setSelectedIndices:(NSMutableArray *)indices
{
	if(indices == nil || [indices count] <= 0) {
		PdfNull *pn = [[PdfNull alloc]init];
		[fieldDictionary setObject:pn forKey:IName];
	} else if([indices count] == 1) {
		PdfNumber *pn = [[PdfNumber alloc] initWithNumber:[indices objectAtIndex:0]];
		[fieldDictionary setObject:pn forKey:IName];
	}
	else  {
		NSMutableArray *ar = [[NSMutableArray alloc]init];
		for(NSNumber *n in indices) {
			PdfNumber *pn = [[PdfNumber alloc]initWithNumber:n];
			[ar addObject:pn];
		}
		PdfArray *par = [[PdfArray alloc] initWithArray: ar];
		[fieldDictionary setObject:par forKey:IName];
	}
}
//
//	Returns array of NSNumbers containing set indices else nil if none or empty
//
-(NSMutableArray *) getSelectedIndices
{
	id  obj = [fieldDictionary objectForKey:IName];
	NSMutableArray *reta = [[NSMutableArray alloc]init];
	
	if(obj == nil || [obj isKindOfClass:[PdfNull class]])		// nada
		return nil;
	
	if([obj isKindOfClass:[PdfNumber class]]) {				// one is the loneliest number
		[reta addObject:obj];
	} else {
		PdfArray *pa = (PdfArray *)obj;
		for (int i =0; i< [pa count]; i++) {
			[reta addObject:[pa objectAtIndex:i]];
		}
	}
	return reta;
}

-(void) drawWithContext:(CGContextRef)ctx andPageRect:(CGRect)pageRect andRotation:(CGPDFInteger) pageRotate		// will be overridden by subclasses
{
	
	CGAffineTransform trans = CGAffineTransformIdentity;
	trans = CGAffineTransformTranslate(trans, 0, pageRect.size.height);
	trans = CGAffineTransformScale(trans, 1.0, -1.0);
	
	CGRect rect = CGRectApplyAffineTransform(where, trans);
	
	rect.origin.y = (pageRect.size.height - rect.origin.y)-rect.size.height;
	
	// do whatever you need with the coordinates.
	// e.g. you could create a button and put it on top of your page
	// and use it to open the URL with UIApplication's openURL
//	NSLog(@"%d, %d, %d, %d", (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height);
	
	CGContextSetRGBFillColor(ctx, 0.0, 1.0,0.0, 0.5);
	CGContextFillRect(ctx, rect);
}

-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect{
    
}

@end
