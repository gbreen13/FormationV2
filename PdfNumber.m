//
//  PdfNumber.m
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfNumber.h"


@implementation PdfNumber
@synthesize number;

//
//	Initialize and advance the read pointer.
//
-(id)initWithString : (NSString *)str
{
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *num = [[f numberFromString:str] retain];
	[f release];
	return [self initWithNumber:num];
}

-(id) initWithNumber:(NSNumber *)num
{
	if(!(self = [super init]))
		return nil;
	number = num;
	return self;
}

-(NSString *)toString
{
	return [number stringValue];
}

-(void) dealloc
{
	[number release];
	[super dealloc];
}

-(int) intValue
{
	return [number intValue];
}
-(int) floatValue
{
	return [number floatValue];
}

@end
