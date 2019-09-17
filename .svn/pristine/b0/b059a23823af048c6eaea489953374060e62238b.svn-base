//
//  PdfString.m
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfString.h"
#define HEX_REGEX @"^([^>]+)>"				// starts then anything other than > then >

@implementation PdfString
@synthesize s, d;

-(int) toNumber:(char) c
{
	if(c >= '0' && c <= '9') return c - '0';
	if(c >= 'a' && c <= 'f') return c - 'a' + 10;
	if(c >= 'A' && c <= 'F') return c - 'A' + 10;
	return -1;
}

//
//	Create from the input stream.. consumes IP
//
-(id) initWithCP: (cstring *)ip andIsHex: (BOOL) ih
{
	if(!(self = [super init]))
		return nil;

	if((isHex = ih)) {
		NSMutableArray *match;
		if ((match = [ip MatchWithRegex:HEX_REGEX])== nil) {
			NSLog(@"EXCEPTION: CAN'T PARSE Hex string");
			return nil;
		}
		
		NSString *hexString = [ip getSubStringFromRange:[[match objectAtIndex:1] rangeValue]];
		
		NSRange r = [[match objectAtIndex:0] rangeValue];
		
		[ip SubString:r.length];  // consume ip

		if([hexString length] & 1) 
			hexString = [hexString stringByAppendingFormat:@"0"];	// force even 
		
		
		unsigned char *buf = malloc([hexString length]+1);
		strcpy((char *)buf, [hexString UTF8String]);
		
		unsigned char c, *cp, *cp2; 
		cp = cp2 = buf;
	
		for(int i=0; i < [hexString length]/2; i++) {
			c = [self toNumber:*cp++] << 4;
			c |= [self toNumber: *cp++];
			*cp2++ = c;
		}
		*cp2 = '\0';
		d = [[NSData alloc]initWithBytes:buf length:[hexString length]/2];
		free(buf);

	} else {
		int nestlevel = 1;
		
		NSMutableString *ms = (NSMutableString *)@"";
		
		BOOL unicode = (([ip length] > 2) && 
						((([ip charAtIndex:0] == 0xfe) && ([ip charAtIndex:1] == 0xff)) ||
						 [ip StartsWith:"\\376\\377"]));
		if(unicode)	{		
			int skip = ([ip charAtIndex:0] == '\\') ? 8 : 2;
			[ip SubString:skip];
		}
			
		while((nestlevel > 0) && ([ip length] > 0)) {
			if([ip charAtIndex:0] == ')' && (nestlevel ==1)) {
				nestlevel = 0;
				[ip SubString:1];
				break;
			}
			
//	Get the next "charaacter".  this also checks for escape chars and replacees them.
			
			NSString *nextc = [ip GetNextCharWithUnicodeFlag: unicode];

			if([nextc length] == 0)
				continue;
//	Parens can be part of the string as well as terminating the string.  bump the nesting level.
			
			if([nextc isEqualToString:@"("]){
				nestlevel++;
			} else if ([nextc isEqualToString:@")"]) {
				nestlevel--;
			}
//	Finally check for the weird case of "\)" and "\("
			if ([nextc isEqualToString:@"\\)"] || [nextc isEqualToString:@"\\("]) {
				nextc = [nextc substringFromIndex:1];
			}
			
			ms = [ms stringByAppendingString:nextc];
				
		}
		self.s = [[NSMutableString alloc] initWithString:ms];		
//		NSLog(@"string: %@", s);
	}
	return self;
}

-(char) toascii: (char) c
{
	if(c >= 0 && c <= 9) return c+'0';
	else return (c + 'a' - 10);
}

-(NSString *)text
{
	if(isHex) {
		NSString *rets = @"";
		for(int i=0; i < [d length]; i++) {
			char c;
			NSRange r = NSMakeRange(i, 1);
			[d getBytes:&c range:r];
			rets = [rets stringByAppendingFormat:@"%c%c", [self toascii:((c>>4) & 0xf)], [self toascii:(c & 0xf)]];
		}
		return rets;
	}
	return s;
}
		
-(NSString *)toString
{
	if(isHex) 
		return [NSString stringWithFormat:@"<%@>", [self text]];
	else 
		return [NSString stringWithFormat:@"(%@)", [self text]];
}
		

@end
