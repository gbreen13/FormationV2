//
//  PdfString.h
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"


@interface PdfString: PdfObject
{
	BOOL isHex;
	NSMutableString *s;
	NSData *d;
}
-(id) initWithCP: (cstring *)ip andIsHex: (BOOL) ih;
-(NSString *)toString;
-(NSString *)text;
@property (nonatomic, copy) NSString *s;
@property (nonatomic, assign) NSData *d;
@end

