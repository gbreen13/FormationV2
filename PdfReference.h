//
//  PdfReference.h
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"


@interface PdfReference : PdfObject
{
	int	objNumber;
	int generationNumber;
}
-(id) initWithNumber: (int)n andGeneration: (int)g;
-(NSString *)toString;
-(int) getObjNumber;
@property int objNumber;
@property int generationNumber;
@end
