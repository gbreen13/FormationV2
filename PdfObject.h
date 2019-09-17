//
//  PdfObject.h
//  Formation
//
//  Created by George Breen on 1/24/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "cstring.h"
#import <Foundation/Foundation.h>

// #define DUMPALL 1
@class PdfComment;
@class PdfName;
@class PdfDictionary;
@class PdfReference;
@class PdfNumber;
@class PdfString;
@class PdfBool;
@class PdfArray;
@class PdfNull;

@interface PdfObject : NSObject {

}
+(id) GetPdfObject:(cstring *)ip;
+(PdfComment *)PdfParseComment:(cstring *)ip;
-(NSString *)toString;				// Must be overwritten
@end






