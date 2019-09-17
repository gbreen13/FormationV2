//
//  PdfReference.m
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfReference.h"


@implementation PdfReference :PdfObject
@synthesize objNumber, generationNumber;
-(id) initWithNumber: (int)n andGeneration: (int)g
{
	if(!(self = [super init]))
		return nil;
	objNumber = n;
	generationNumber = g;
	return self;
}

-(NSString *)toString
{
	return [NSString stringWithFormat:@"%d %d R", objNumber, generationNumber];
}
-(int) getObjNumber
{
	return objNumber;
}

@end
