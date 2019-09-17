//
//  cstring.m
//  Formation
//
//  Created by George Breen on 1/25/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "cstring.h"
//
//	Emulate the C# constructs to simply porting.
//

BOOL isWhiteSpace(char ch)
{
	return
	ch == '\000' ||
	ch == '\011' ||
	ch == '\012' ||
	ch == '\014' ||
	ch == '\015' ||
	ch == '\040';
}
	
@implementation cstring
@synthesize data,start, rp, len;

-(id)initWithData:(NSData *)d
{
	if((self =[super init]) == nil) 
		return nil;
	data = d;
	len = [data length];	// how many bytes left after *ip
	start = rp = (char *)[data bytes];
	return self;
}
-(id)initWithData:(NSData *)d andRange:(NSRange)r
{
	if((self =[super init]) == nil) 
		return nil;
	data = d;
//	len = [data length] - r.length;	// how many bytes left after *ip
	len =  r.length;	// how many bytes left after *ip
	start = (char *)[data bytes];
	rp = start + r.location;
	return self;
}

//
//	Just bump the cp up by length
//
-(void) SubString:(int)l
{
	l = MIN(len, l);
	rp += l;
	len -= l;
}

-(unsigned char)charAtIndex:(int)i
{
	return *(rp + i);
}

-(BOOL) isOct: (unsigned char)c
{
	return (c >= '0' && c <= '7');
}

-(unsigned char)consumeNextChar
{
	if(len > 0) {
		len--;
		return *(rp++);
	}
	return '\0';
}
static unsigned char workbuf[256];

-(unsigned char *) GetNextInputChar {
	int clen = 1;
	char currentChar = [self charAtIndex:0];
	char nextCharacter = [self charAtIndex:1];
	
	unsigned char *wp = workbuf;
	
	*wp = '\0';
	
	if (len >= 2
		&& currentChar == '\\')
	{
		clen += 1; // strip the \
		
		switch (nextCharacter)
		{
			case ')':
			case '(':
			case '\\':
				*wp++ = '\\';
				*wp++ = nextCharacter;
				break;
			case 'n':
				*wp++ =  '\n';
				break;
			case 'r':
				*wp++ = '\r';
				break;
			case 't':
				*wp++ = '\t';
				break;
			case 'b':
				*wp++ = '\b';
				break;
			case 'f':
				*wp++ = '\f';
				break;
	
			default:
				if(1);
				char c2 = [self charAtIndex:2];
				char c3 = [self charAtIndex:3];
				
				if([self isOct:nextCharacter] && [self isOct:c2] && [self isOct:c3]) 
				{
					int num = (nextCharacter -'0')*64 +
								([self charAtIndex:2]-'0')*8 +
					([self charAtIndex:3]-'0');
					*wp++ = (unsigned char) num;
					clen += 2;
				}
				break;
		}
	}
	else if (len >= 2 && (currentChar == '\n' || currentChar == '\r'))
	{
		*wp++ = '\n';
		
		if (nextCharacter == '\n' || nextCharacter == '\r') // two-byte line ending
		{
			clen += 1;
		}
	}
	else
	{
		*wp++ = currentChar;
	}
	
	*wp = '\0';
	
	[self SubString:clen];		// advance rp
	
	return workbuf;
}

-(NSString *)GetNextCharWithUnicodeFlag: (BOOL) unicode
{
	unsigned char *cp = [self GetNextInputChar];

	if(*cp == '\0') {

		return [NSString stringWithFormat:@""];
	}
	
	if (unicode)
	{

		unsigned char c2[4];
		c2[0] = *cp;
		while(1) {
			c2[1] = *(char *)[self GetNextInputChar];
			if(c2[1] != '\0') break;
		}
		c2[3] = '\0';
		return [NSString stringWithCString:(char *)c2 encoding:NSUnicodeStringEncoding];
	}
	return [NSString stringWithCString:(char *)cp encoding:NSUTF8StringEncoding];
}

-(void) trimStart
{
	while(*rp && isWhiteSpace(*rp) && len > 0) {
		rp++; len--;
	}
}

-(id)initWithString: (NSString *)s
{
	return [self initWithData:[s dataUsingEncoding:NSASCIIStringEncoding]];
}
		
-(id) initFromCharP: (char *)cp
{
	NSData *d = [NSData dataWithBytes:(const void *)cp length:strlen(cp)];
	return [self initWithData:d];
}

//
//	See if the pattern matches the characters at the current read pointer.
//
-(BOOL) StartsWith: (char *)pattern
{
	return (strstr(rp, pattern) == rp);				// is it at the beginning of the data pointer?
}

//
//	return the substring between from and end as offset by the read pointer.
//
-(NSString *)getSubStringFrom: (int) from to: (int)end
{
	char *sp = rp + from;
	NSData *dp = [NSData dataWithBytes:sp length:(MIN(len, end-from))];
	NSString *rets = [[[NSString alloc] initWithBytes:[dp bytes] length:[dp length] encoding:NSASCIIStringEncoding]autorelease];
	return rets;
}
-(NSString *)getSubStringFromRange: (NSRange)r
{
	return [self getSubStringFrom: r.location to: r.location+r.length];
}

//
//	Return multiple matches of regular expression pattern in data between (ip + start and ip + end]
//	Returns an array for each match.  Each match array is in turn an array of NSValue container objects holding the range matches.
//
-(NSMutableArray *) MatchesWithRegex: (NSString *)pattern betweenStart: (int)st andEnd: (int)end
{
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	
	if(!regex) {
		NSLog(@"Error creating regex from pattern: %@", pattern);
		return nil;
	}
	char *cp =rp + st;
//
//	Make a nsstring that's a subset of the NSData between start and end.
//
	NSString *str = [[NSString alloc] initWithBytes:cp length:(end-st) encoding:NSASCIIStringEncoding];
	
	NSArray *ar = [regex matchesInString:str options:0 range:NSMakeRange(0,[str length])]; 
//
//	If we found a hit, go through all of the locations and add back in the start number to the location
//
	NSMutableArray *mret = nil;
	if(ar) {
		mret = [NSMutableArray arrayWithCapacity:[ar count]];
		for(int i=0; i < [ar count]; i++) {
			NSTextCheckingResult *tr = [ar objectAtIndex:i];
			NSMutableArray *trarray = [NSMutableArray arrayWithCapacity:[tr numberOfRanges]];
			for(int j = 0; j < [tr numberOfRanges]; j++) {
				NSRange r= [tr rangeAtIndex:j];
				if(r.location != NSNotFound) 
					r.location += st;
				[trarray addObject:[NSValue valueWithRange:r]];
			}
			[mret addObject:trarray];
		}
	}
	[str release];
	return mret;
			
}
-(NSMutableArray *) MatchesWithRegex: (NSString *)pattern fromStart: (int)st forLength: (int)length
{
	return [self MatchesWithRegex:pattern betweenStart:st andEnd:st+length];
}
//
//	Return single of regular expression pattern in data between (ip + start and ip + end]
//
-(NSMutableArray *) MatchWithRegex: (NSString *)pattern betweenStart: (int)st andEnd: (int)end

{
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	
	if(!regex) {
		NSLog(@"Error creating regex from pattern: %@", pattern);
		return nil;
	}
	
	char *cp =rp + st;
	//
	//	Make a nsstring that's a subset of the NSData between start and end.
	//
	NSString *str = [[NSString alloc] initWithBytes:cp length:(end-st) encoding:NSASCIIStringEncoding];
	NSMutableArray *aret= nil;
	NSTextCheckingResult *tr = [regex firstMatchInString:str options:0 range:NSMakeRange(0,[str length])]; 
	
	//
	//	If we found a hit, go through all of the locations and add back in the start number to the location
	//
	if(tr) {
//XXX		aret = [[[NSMutableArray alloc] initWithCapacity:[tr numberOfRanges]]autorelease];
		aret = [[NSMutableArray alloc] initWithCapacity:[tr numberOfRanges]];
		for(int j = 0; j < [tr numberOfRanges]; j++) {
			NSRange r= [tr rangeAtIndex:j];
			if(r.location != NSNotFound) {
				r.location += st;
			}
			[aret addObject:[NSValue valueWithRange:r]];
		}
	}
	[str release];
	return aret;
}

-(NSMutableArray *) MatchWithRegex: (NSString *)pattern
{
	return [self MatchWithRegex:pattern fromStart:0 forLength: len];
}
-(NSMutableArray *) MatchWithRegex: (NSString *)pattern fromStart: (int)st forLength: (int)length
{
	return [self MatchWithRegex:pattern betweenStart:st andEnd:st+length];
}


//
//	Search backwards for pattern.  Search is between rp and end, starts at end and returns index if found else -1.
//
-(int)LastIndexOf:(char *)pattern from:(int)po {		// find last occurance of pattern going backwards from po to cp
	
	NSRange r = NSMakeRange((rp - start), po);
	
	if((r.location + strlen(pattern)) < po) {
		NSRange firstEndobjFound = [data rangeOfData:[NSData dataWithBytes:pattern length:strlen(pattern)] 
											 options:NSDataSearchBackwards
											   range:r];
		if(firstEndobjFound.location != NSNotFound)
			return(firstEndobjFound.location += (rp - start));
	}
	return -1;	// not found
}
					 
-(int)IndexOf: (char *)pattern								// return first occurance
{
	NSRange r = NSMakeRange(rp - start, [data length] - (rp - start));		// range = read pointer to end of buffer.
	NSRange firstFound = [data rangeOfData:[NSData dataWithBytes:pattern length:strlen(pattern)] 
										 options:NSBackwardsSearch
										   range:r];
	return (firstFound.location == NSNotFound) ? -1 : firstFound.location + (rp - start);
}
-(int)IndexOf:(char *)pattern from:(int)st
{
	NSRange r = NSMakeRange((rp - start)+st, [data length] - ((rp - start)+st));		// range = read pointer to end of buffer.
	NSRange firstFound = [data rangeOfData:[NSData dataWithBytes:pattern length:strlen(pattern)] 
								   options:NSBackwardsSearch
									 range:r];
	return (firstFound.location == NSNotFound) ? -1 : firstFound.location + (rp - start);
}

-(int) length
{
	return len;
}

		
@end
