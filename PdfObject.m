//
//  PdfObject.m
//  Formation
//
//  Created by George Breen on 1/24/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfObject.h"
#import "PdfName.h"
#import "PdfDictionary.h"
#import "PdfReference.h"
#import "PdfNumber.h"
#import "PdfString.h"
#import "PdfBool.h"
#import "PdfArray.h"
#import "PdfComment.h"
#import "PdfNull.h"


#define BOOL_REGEX @"^((true)|(false))"
#define COMMENT_REGEX @"^%([^\\u000a\\u000d]*)"		// starts then % then 0 or more CR LFs in unichar.
//#define NAME_REGEX @"^/\\S+"							//#define NAME_REGEX @"^(/[^\\s()<>{}/%[\\]]+)"
#define NAME_REGEX @"^(/[^\\s/\()\\<\\>\\\{\\}%\\[\\]]+)"
#define STRING_REGEX @"^(<|\()"						// starts then either left < OR left (
#define ARRAY_REGEX @"^\\["							// starts then left  bracket.
#define NULL_REGEX @"^null"							// starts then null
#define REFERENCE_REGEX @"^(\\d+)\\s+(\\d+)\\s+R"	// starts then a number then white space then a number then white space then R
#define DICTIONARY_REGEX @"^<<"						// starts then <<
#define NUMBER_REGEX @"^((-|\\+)?\\d*\\.?\\d*)"		// starts then either - or plus (0 or more times) number, possibly a decimal point then another number.

@implementation PdfObject

+(id) GetPdfObject:(cstring *)ip
{
	NSMutableArray *match;
	
	[ip trimStart];
	if([ip StartsWith: "true"]) {
		[ip SubString:4];
		return [[PdfBool alloc] initWithVal:TRUE];
	}
	
	if([ip StartsWith: "false"]) {
		[ip SubString:5];
		return [[PdfBool alloc] initWithVal:FALSE];
	}
	
	if ([ip StartsWith:"/" ])  {
		if ((match = [ip MatchWithRegex:NAME_REGEX])) {

			NSRange r = [[match objectAtIndex:0] rangeValue];
			NSString *name = [ip getSubStringFromRange:r];
//			NSLog(@"Parsing PdfName (%@)",name);
			r = [[match objectAtIndex:0] rangeValue];
			[ip SubString:r.length];
			return [[PdfName alloc] initWithName:name];
		} else {
			//	check for NO name (e.g. //)
			[ip SubString:1];
			return [[PdfName alloc] initWithName:@"/"];
		}
	}
	if([ip StartsWith:"<<"]) {
		[ip SubString:2];
#ifdef DUMPALL
		NSLog(@"Parsing dictionary");
#endif
		return [[PdfDictionary alloc] initWithCP:ip];
	}
	
	if (([ip length] > 0) && [ip StartsWith:"<"]) {
		[ip SubString:1];
#ifdef DUMPALL
		NSLog(@"Parsing string");
#endif
		return [[PdfString alloc] initWithCP:ip andIsHex:TRUE];
	}
	if (([ip length] > 0) && [ip StartsWith:"("]) {
		[ip SubString:1];
#ifdef DUMPALL
	NSLog(@"Parsing string");
#endif
		return [[PdfString alloc] initWithCP:ip andIsHex:FALSE];
	}
	
	if ([ip StartsWith:"["])
	{
		[ip SubString:1];
#ifdef DUMPALL
		NSLog(@"Parsing array");
#endif
		return [[PdfArray alloc]initWithCP:ip];
	}
	
	if ([ip StartsWith:"null"])
	{
		[ip SubString:4];
#ifdef DUMPALL
		NSLog(@"Parsing array");
#endif
		return [[[PdfNull alloc]init]autorelease];
	}
	
	if ((match = [ip MatchWithRegex:REFERENCE_REGEX])!= nil) {
		NSRange r = [[match objectAtIndex:0] rangeValue];
		int objNumber = [[ip getSubStringFromRange:[[match objectAtIndex:1] rangeValue]] intValue];	
		int generationNumber = [[ip getSubStringFromRange:[[match objectAtIndex:2] rangeValue]] intValue];
		[ip SubString:r.length];
#ifdef DUMPALL
		NSLog(@"Parsing reference");
#endif
		return [[PdfReference alloc] initWithNumber:objNumber andGeneration:generationNumber];
	}
	
	if ((match = [ip MatchWithRegex:NUMBER_REGEX]) != nil) {
		NSRange r = [[match objectAtIndex:0] rangeValue];
#ifdef DUMPALL
		NSLog(@"Parsing number");
#endif
		PdfNumber *retn = [[PdfNumber alloc] initWithString:[ip getSubStringFromRange:[[match objectAtIndex:1] rangeValue]]];
		[ip SubString:r.length];
		return retn;
	}
	

//
//	If we get here, it'd better be a comment.
//

	PdfComment *cret = [self PdfParseComment:(cstring *)ip];
	if(cret != nil)
		return cret;
	NSLog(@"invalid PDF file");
	return nil;
}

+(PdfComment *)PdfParseComment:(cstring *)ip
{
	NSMutableArray *match;
	if ((match = [ip MatchWithRegex:COMMENT_REGEX]) != nil) {
		NSRange r = [[match objectAtIndex:0] rangeValue];
		NSString *comment = [ip getSubStringFromRange:[[match objectAtIndex:1] rangeValue]];	
		[ip SubString:r.length];
		return [[PdfComment alloc]initWithString:comment];
	}
	return nil;
}
-(NSString *)toString
{
	return @"";
}

@end

