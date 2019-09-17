//
//  PdfPageTreeNode.h
//  Formation
//
//  Created by George Breen on 2/1/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PdfDictionary;
@class PdfArray;
@class PdfReader;

@interface PdfPageTreeNode : NSObject {
	int objectNumber;
	int generationNumber;
	PdfDictionary *pagesDictionary;			/* original dictionary */
	NSMutableArray	*Kids;						/* array of either Page Node or Page object */
	PdfArray *KidsRefArray;				/* array of kid references */
	PdfDictionary *Parent;
	NSString *original;
	int	Count;		// how many pages are referred to by this node.
}

@property (nonatomic, assign) PdfDictionary *pagesDictionary,  *Parent;
@property (nonatomic, assign) PdfArray *KidsRefArray;
@property (nonatomic, assign) NSMutableArray *Kids;
@property (nonatomic, copy) NSString *original;
@property int Count, objectNumber, generationNumber;

-(id) initWithObjno: (int) on andGeneration: (int) gen andDictionary: (PdfDictionary *) fdict andReader: (PdfReader* )reader;
-(NSString *)toString;
-(BOOL) hasChanged;
-(NSString *)getString;

@end
