//
//  PdfComment.m
//  Formation
//
//  Created by George Breen on 1/27/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "PdfComment.h"

@implementation PdfComment
@synthesize comment;

-(id) initWithString: (NSString *)s
{
	if(self = [super init]) {
		self.comment = s;
	}
	return self;
}

-(NSString *)toString
{
	NSString *rets = @"%";
	[rets stringByAppendingString:comment];
	return rets;
}

@end
