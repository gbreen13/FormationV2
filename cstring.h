//
//  cstring.h
//  Formation
//
//  Created by George Breen on 1/25/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cstring : NSObject {
	NSData *data;
	int	 len;
	char *start;	// beginning of the data bytes
	char *rp;		// current read  pointer.
}

-(id)initWithData:(NSData *)d;
-(id)initWithData:(NSData *)d andRange:(NSRange)r;
-(id)initWithString: (NSString *)s;
-(id) initFromCharP: (char *)cp;
-(void) trimStart;
-(void) SubString: (int) len;
-(BOOL) StartsWith: (char *)pattern;
-(NSMutableArray *) MatchWithRegex: (NSString *)pattern betweenStart: (int)st andEnd: (int)end;
-(NSMutableArray *) MatchWithRegex: (NSString *)pattern fromStart: (int)st forLength: (int)length;
-(NSMutableArray *) MatchWithRegex: (NSString *)pattern;
-(NSMutableArray *) MatchesWithRegex: (NSString *)pattern betweenStart: (int)start andEnd: (int)end;
-(NSMutableArray *) MatchesWithRegex: (NSString *)pattern fromStart: (int)start forLength: (int)length;
-(int)LastIndexOf:(char *)pattern from:(int)po;		// find last occurance of pattern going backwards from po.
-(int)IndexOf: (char *)pattern;								// return first occurance
-(int)IndexOf:(char *)pattern from:(int)st;
-(id)initWithString: (NSString *)s;
-(NSString *)getSubStringFrom: (int) from to: (int)end;
-(NSString *)getSubStringFromRange: (NSRange)r;
-(int) length;
-(unsigned char)charAtIndex:(int) index;
-(unsigned char *) GetNextInputChar;
-(NSString *)GetNextCharWithUnicodeFlag: (BOOL) unicode;

@property (nonatomic, assign) NSData *data;
@property char *start, *rp;
@property int len;
@end
