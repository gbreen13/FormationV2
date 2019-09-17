//
//  PdfDictionary.h
//  Formation
//
//  Created by George Breen on 1/26/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"

@class PdfReader;
@interface PdfDictionary : PdfObject
{
	NSMutableDictionary *dictionary;
}
-(id) initWithString: (NSString *)str;
-(id) initWithCP: (cstring *)ip;
-(id) initWithDictionary: (PdfDictionary *)dict;
-(NSString *)toString;
-(id) objectForKey:(NSString *) key;
-(id) objectForKeyWithIndirect:(NSString *)key;
-(id) objectDeepForKey:(NSString *) key withReader: (PdfReader *)reader;
-(void) setObject: (id)obj forKey: (NSString *)key;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
- (void)removeObjectForKey:(NSString *)defaultName;
@property (nonatomic, assign) NSMutableDictionary *dictionary;
@end
