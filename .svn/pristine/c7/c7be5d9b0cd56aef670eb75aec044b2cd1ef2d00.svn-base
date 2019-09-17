//
//  PdfDictionary.m
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfDictionary.h"
#import "PdfReader.h"

#define END_REGEX @"^>>"
#define KEY_REGEX @"^(/[^\\s/\()\\<\\>\\\{\\}%\\[\\]]+)"		// GEB DON'T THINK THIS REGEX IS RIGHT FOR THE NAMES

@implementation PdfDictionary
@synthesize dictionary;

-(id) initWithCP: (cstring *)ip
{
	if(!(self = [super init])) return nil;

	BOOL match;
	NSMutableArray *keyMatch;
	
	dictionary = [[NSMutableDictionary alloc]init];
	[ip trimStart];
	for(match = [ip StartsWith:">>"]; !match && ([ip length]>0); match = [ip StartsWith:">>"]) {

		if(keyMatch = [ip MatchWithRegex:KEY_REGEX]) {
			NSRange r = [[keyMatch objectAtIndex:0] rangeValue];
			NSString *keyStr = [ip getSubStringFromRange:r];
			[ip SubString:r.location + r.length];
			[dictionary setObject:[PdfObject GetPdfObject:ip] forKey:keyStr];
		} else {
			if ([PdfObject PdfParseComment:ip] == nil) {
				NSString *emsg = [NSString stringWithFormat:@"Cannot parse dictionary from: %@", [ip getSubStringFrom:0 to: MAX([ip length], 50)]];
				NSLog(@"fatal %@",emsg);
			}
		}
		[ip trimStart];
	}
	if(match)
		[ip SubString:2];
	return self;
}

-(id) initWithDictionary: (PdfDictionary *)dict
{
	if(!(self = [super init])) return nil;

	dictionary = [[NSMutableDictionary alloc]init];
	for(id theKey in dict) {
		PdfObject *pObj = (PdfObject *)[dict objectForKey:theKey];
		[dictionary setObject:pObj forKey:theKey];
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
//
//	Looks in the dictionary for the item.  If the item is an indirect object,
//	drill down.
//
-(id) objectDeepForKey:(NSString *) key withReader: (PdfReader *)reader
{
	PdfObject *obj = [dictionary objectForKey:key];
//
//	If indirect, go deep.
	while ([obj isKindOfClass:[PdfReference class]])
		obj = [reader GetPdfObjectFromReference: (PdfReference *)obj];
	return obj;
}

-(id) objectForKey:(NSString *) key
{
	return [dictionary objectForKey:key];
}
-(id) objectForKeyWithIndirect:(NSString *)key
{
	PdfObject *pObj = [dictionary objectForKey:key];
	if([pObj isKindOfClass:[PdfReference class]]) 
		pObj = [sharedPdfReader GetPdfObjectFromReference:(PdfReference *)pObj];
	return pObj;
}

-(void) setObject: (id)obj forKey: (NSString *)key
{
	[dictionary setObject:obj forKey:key];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [dictionary countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len];
}
- (void)removeObjectForKey:(NSString *)defaultName
{
	return [dictionary removeObjectForKey:(NSString *)defaultName];
}

-(NSString *)toString
{
	NSString *rets = @"<<\n";
	for (id theKey in dictionary) {
		PdfObject *pObj = (PdfObject *)[dictionary objectForKey:theKey];
		rets = [rets stringByAppendingFormat:@"%@ %@\n", theKey, [pObj toString]];// retain
	}
	rets = [rets stringByAppendingFormat:@" >>"];
	return rets;
}

@end
