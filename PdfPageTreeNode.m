//
//  PdfPageTreeNode.m
//  Formation
//
//  Created by George Breen on 2/1/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfPageTreeNode.h"
#import "PdfReader.h"


@implementation PdfPageTreeNode
@synthesize objectNumber, generationNumber, Kids, KidsRefArray, Count;
@synthesize pagesDictionary, Parent, original;

-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) pd andReader: (PdfReader*)reader
{
	if((self = [super init]) == nil) 
		return nil;

	objectNumber = on;
	generationNumber = gen;
	pagesDictionary = pd;
	Kids = [[NSMutableArray alloc]init];
	
	KidsRefArray = [pagesDictionary objectForKey:@"/Kids"];	// array of references.
	Parent = [pagesDictionary objectForKey:@"/Parent"];
	Count = [(PdfNumber *)[pagesDictionary objectForKey:@"/Count"]intValue];
	
	for(NSObject *pObj in KidsRefArray) {
		if ([pObj isKindOfClass: [PdfReference class]]) {		//	better be.
			PdfDictionary *KidDict  = (PdfDictionary *)[reader GetPdfObjectFromReference: (PdfReference *)pObj];
			PdfName *KidType = [KidDict objectForKey:@"/Type"];
			if ([KidType isEqualToString:@"/Page"]) {
				PdfPage *page = [[PdfPage alloc]initWithObjno:((PdfReference *)pObj).objNumber 
												andGeneration:((PdfReference *)pObj).generationNumber 
												andDictionary:KidDict
													andReader:reader];
				[Kids addObject:page];
			} else if ([KidType isEqualToString:@"/Pages"]) {
				PdfPageTreeNode *pageNode = [[PdfPage alloc]initWithObjno:((PdfReference *)pObj).objNumber 
												andGeneration:((PdfReference *)pObj).generationNumber 
												andDictionary:KidDict
													andReader:reader];
				[Kids addObject:pageNode];
			}
		}
	}
		
	self.original = [self toString];
	return self;
}

-(BOOL) hasChanged
{
	return [original isEqualToString:[self toString]];
}

-(NSString *)toString
{
	return [self getString];
}

-(NSString *)getString
{
	NSString *rets = [NSString stringWithFormat:@"%d %d <<\n/Type /Pages\n/Count %d\n",objectNumber, generationNumber, Count];
	if(Parent)
		rets = [rets stringByAppendingFormat:@"/Parent %@\n", [Parent toString]];
	
	rets = [rets stringByAppendingFormat:@"/Kids %@\n", [KidsRefArray toString]];
	
	return rets;
}

-(void) dealloc
{
	[Kids release];
	[KidsRefArray release];	Parent = [pagesDictionary objectForKey:@"/Parent"];
	[Count release];
	[Parent release];
	[original release];
	[super dealloc];
}
	
@end
