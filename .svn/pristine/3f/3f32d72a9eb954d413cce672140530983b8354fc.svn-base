//
//  XrefEntry.h
//  Formation
//
//  Created by George Breen on 1/18/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfObject.h"

//
//	We extract the cross reference table from the file.  Through changes in file format, the xref table has changed as well.
//	The basic xref is a byte offset from the beginning of the file.  This is type 1.
//	The next type of reference

#define kObjectIsAbsoluteOffset	1
#define kObjectIsContainedInAnotherObject 2

@interface XrefEntry : NSObject {
	int	objNumber;			// The objec number.
	int	generationNumber;	// the generation number of the LAST version of this object.
	int	offset;
	BOOL active;
	BOOL changed;			// flag when writing updates.
	PdfObject	*pObj;		// parsed object. once parsed we return this.
	BOOL embeddedObject;	// if this object is contained in another stream object.
	int refObject;			// which object this is contained in.
	int refIndex;			// the byte offset within the object where this is.
}
	
-(id) initWithObjectNumber: (int)number andGenerationNumber: (int)gen andOffset: (int)off andActive:(BOOL)a;
-(void) setUpdate;
-(void) setInactive;
-(BOOL) isActive;
-(int) getOffset;

@property int objNumber, generationNumber, offset, refObject, refIndex;
@property BOOL active, embeddedObject;
@property (nonatomic, assign) PdfObject *pObj;
	
@end
