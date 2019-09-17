//
//  PdfBool.h
//  Formation
//
//  Created by George Breen on 1/27/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"


@interface PdfBool : PdfObject

{
	BOOL	val;
}
-(id) initWithVal:(BOOL)v;
@property BOOL val;
@end


