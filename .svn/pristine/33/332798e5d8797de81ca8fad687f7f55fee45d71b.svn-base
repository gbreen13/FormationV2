//
//  PdfArray.h
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"


@interface PdfArray : PdfObject 
{
	NSMutableArray *array;
}
-(id) initWithString: (NSString *)str;

-(id) initWithCP: (cstring *)ip;
-(id) initWithArray: (NSMutableArray *) ar;
-(NSString *)toString;
-(int) count;
-(void) removeRedundancies;
-(void) removeAllObjects;

-(id) objectAtIndex:(int)i;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
@property (nonatomic, assign) NSMutableArray *array;
@end