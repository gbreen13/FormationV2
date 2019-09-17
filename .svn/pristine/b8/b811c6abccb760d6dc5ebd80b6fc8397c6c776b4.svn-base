//
//  PdfArray.m
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfArray.h"
#import "PdfReference.h"

/// Initializes a new PdfArray object.
/// Must not contain the leading '['. Must contain the trailing ']'. 
/// The PdfArray is consumed from the input.

@implementation PdfArray
@synthesize array;
-(id) initWithCP: (cstring *)ip
{
	if((self = [super init]) == nil) return nil;
	
	[ip trimStart];
	
	array = [[NSMutableArray alloc]init];
	BOOL match;
	
	for (match = [ip StartsWith:"]"]; !match && [ip length] > 0; match = [ip StartsWith:"]"])
	{
		[array addObject:[PdfObject GetPdfObject:ip]];
		[ip trimStart];
	}
	
	if (match)
	{
		[ip SubString:1];	// skip over last ]
	}
	return self;
}

-(id) initWithString:(NSString *)str
{
	cstring *ip = [[cstring alloc]initWithString:str];
	id ret = [self initWithCP:ip];
	[ip release];
	return ret;
}
																			   
-(id) initWithArray: (NSMutableArray *) a
{
	if((self = [super init]) == nil) return nil;
	
	array = [[NSMutableArray alloc]init];
	for(id obj in a) {
		[array addObject:obj];
	}
	return self;
}
																			   
-(NSString *)toString
{
	NSString *rets = @"[ ";
	
	for(PdfObject *p in array) 
		rets = [rets stringByAppendingFormat:@"%@ ",[p toString]];
	
	rets = [rets stringByAppendingString:@"]"];
	return rets;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len];
}
-(void) removeAllObjects
{
	[array removeAllObjects];
}
//
//	This should be an array of PdfReferences.  Remove the redundant ones.
//

-(void) removeRedundancies
{
	NSMutableArray *save = [[[NSMutableArray alloc]init]autorelease];
	id pObj;

	for(pObj in array) {
		if(![pObj isKindOfClass:[PdfReference class]]) 
			return;
		
		if(![save containsObject:pObj])
			[save addObject:pObj];
		else {
			NSLog(@"PdfArray: Found redundancy: %@", [self toString]);
		}
	}
	
	[array removeAllObjects];
	for(pObj in save)
		[array addObject:pObj];
}

-(int) count
{
	return [array count];
}

-(id) objectAtIndex:(int)i
{
	return [array objectAtIndex:i];
}

@end
