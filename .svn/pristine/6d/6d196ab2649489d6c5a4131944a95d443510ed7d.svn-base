//
//  PdfBool.m
//  Formation
//
//  Created by George Breen on 1/27/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfBool.h"


@implementation PdfBool : PdfObject
@synthesize val;

-(id) initWithVal:(BOOL)v
{
	if(self = [super init])
		val = v;
	return self;
}

-(NSString *)toString
{
	return val ? @"true" : @"false";
}

@end

