//
//  PdfNumber.h
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"



@interface PdfNumber : PdfObject
{
	 NSNumber *number;
}
-(id)initWithNumber: (NSNumber *)num;
-(id)initWithString: (NSString *)str;
-(NSString *)toString;
-(int) intValue;
-(int) floatValue;
@property (nonatomic, assign) NSNumber *number;

@end

