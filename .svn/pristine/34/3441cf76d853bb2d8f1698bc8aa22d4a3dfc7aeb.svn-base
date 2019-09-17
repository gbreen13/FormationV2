//
//  XrefEntry.m
//  Formation
//
//  Created by George Breen on 1/18/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "XrefEntry.h"



@implementation XrefEntry
@synthesize offset, active, generationNumber, objNumber, pObj, refIndex, refObject, embeddedObject;

-(void) setUpdate
{
	changed=YES;
}

-(void) setInactive
{
	active = NO;
	changed = YES;
}

-(BOOL) isActive
{
	return active;
}

-(int)getOffset
{
	return offset;
}

-(id) initWithObjectNumber: (int)number andGenerationNumber: (int)gen andOffset: (int)off andActive:(BOOL)a
{
	if(self = [super init]) {
		objNumber = number;
		generationNumber = gen;
		offset = off;
		active = a;
		pObj = nil;
	} 
	return self;
}


@end
