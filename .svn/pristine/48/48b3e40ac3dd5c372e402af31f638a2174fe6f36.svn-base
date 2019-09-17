//
//  PdfName.m
//  PDFFileTest
//
//  Created by George Breen on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PdfName.h"


@implementation PdfName
@synthesize name;

//
//	Names may have special hex code characters in them.  These are identified with a #xx which xxis the hex code.
//	we'll convert back to the original bytecode.
//
-(BOOL) ishex: (char) c
{
	if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))
		return TRUE;
	return FALSE;
}

-(int) toNumber:(char) c
{
	if(c >= '0' && c <= '9') return c - '0';
	if(c >= 'a' && c <= 'f') return c - 'a' + 10;
	if(c >= 'A' && c <= 'F') return c - 'A' + 10;
	return -1;
}
		

-(NSString *)parseName:(NSString *)nm
{
	char buf[256], buf2[256];
	
	strcpy(buf, "/");
	char *cp1 = &buf[1];
	
	char *cp2 = &buf2[0];
	strncpy(buf2, [nm UTF8String], sizeof(buf2)-1);
	
	
	for(int i = 0; i < [nm length]; i++) {
		*cp1 = *cp2++;
		if (*cp1 == '#') {
			if ([self ishex:cp2[0]] &&
				[self ishex:cp2[1]]) {
					 *cp1 = [self toNumber:cp2[0]] * 16 + 
							[self toNumber:cp2[1]];
					 cp2 +=2;
			}
		}
		cp1++;
	}
	*cp1 = '\0';
	return ([NSString stringWithUTF8String:buf]);														   
//	return ([NSString stringWithCString:buf encoding:NSUTF8StringEncoding]);														   
}

-(char) toasc: (int) a
{
	if(a <= 9) return a + '0';
	else return a + 'A' - 10;
}

//
//	Put back into original format.
//
-(NSString *)UnParseName:(NSString *)nm
{
	unsigned char a;
	char buf[256], buf2[256], *cp1, *cp2;
	
	cp1 = buf;
	cp2 = buf2;
	
	strncpy(buf, [nm UTF8String], sizeof(buf)-1);
	
	while(a = *cp1++) {
		if((a <= 0x20) || (a > 0x7f)) {
			cp2[0] = '#'; cp2[1] = [self toasc:a/16]; cp2[2] = [self toasc:a & 0xf];
			cp2 += 3;
		} else {
			*cp2++ = a;
		}
	}
	*cp2 = '\0';
	
	return ([NSString stringWithCString:(char *)buf2 encoding:NSUTF8StringEncoding]);														   
}


-(id) initWithName: (NSString *) nm
{
	if(self = [super init]) {
		if(![[nm substringToIndex:1] isEqualToString:@"/"])
			NSLog(@"ALERT: Name Doesn't Begin with /");
		else {
			self.name = [self parseName:[nm substringFromIndex:1]];
		}
	}
	return self;
}



-(BOOL) isEqualToString: (NSString *)str
{
	return [name isEqualToString:str];
}

-(BOOL) isEqualTo: (id)obj
{
	return ([obj isKindOfClass:[PdfName class]] &&
			[name isEqualToString:[(PdfName *)obj name]]);
}

-(NSString *) toString
{
	return [NSString stringWithFormat:@"%@", name];
}
			
@end
