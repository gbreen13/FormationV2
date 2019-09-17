//
//  PdfReader.m
//  Formation
//
//  Created by George Breen on 1/28/11.

//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FormationErrors.h"
#import "PdfReader.h"
#import "NSDATAExtensions.h"

#define XREF_REGEX @"startxref\\s*(\\d+)\\s*%%EOF" 
#define STARTXREF_REGEX @"startxref\\s*(\\d+)" 
#define TRAIL_REGEX @"trailer\\s+<<(.*>>)(\\s+startxref\\s+(\\d+))?" 
#define REF_REGEX @"\\s*((\\d+)\\s+(\\d+))?\\s*(\\d{10})\\s+(\\d{5})\\s+(n|f)"
#define LINEAR_REGEX @"/Linearized\\s+1"
#define OBJECT_REGEX @"(\\d+)\\s+(\\d+)\\s+obj(.*?)endobj"		// number, then number, then "obj" then stuff then "endobj"
#define OBJ_REGEX @"(\\d+)\\s+(\\d+)\\s+obj"		// number, then number, then "obj" then stuff then "endobj"
#define STREAM_REGEX @"stream(.*?)endstream"
#define OBJECTPAIR_REGEX @"(\\d+)\\s+(\\d+)\\s+"

@implementation PdfReader
@synthesize pdf, fd, filePath, objectTable, trailerString, offsetTable, form, pageTreeNode, endOfFile;
@synthesize fields, myDocumentRef, myPageRef, curPage, allPageObjects, changes, totalPages;
@synthesize annotations, page, PDFInput, fieldsByName,formAnnotations, previous, rootObjectNumber, rootGeneration, newTrailerFormat;


-(BOOL) loadFileWithURL: (NSURL *) furl error: (NSError **)error
{
	
	self.filePath = furl;
	fd = [[NSFileHandle fileHandleForReadingFromURL:(filePath) error:error] retain];
	
	if(!fd) {
		return FALSE;
	}
	
	if(pdf == nil)
		self.pdf = [fd readDataToEndOfFile];
	
	if(pdf == nil) {
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:kPDFFileReadErrorText forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:kFormationErrorDomain code:kPDFFileReadError userInfo:errorDetail];
		[self unloadFile];
		return FALSE;
	}
	
	endOfFile = [pdf length];				// know where the last byte is for tacking on changes.
	lastObject = 0;
	newTrailerFormat = FALSE;
	isLinearized = FALSE;
	objectTable = [[NSMutableDictionary alloc]init];
	offsetTable = [[NSMutableArray alloc]init];
	fields = [[NSMutableArray alloc]init];
	fieldsByName = [[NSMutableDictionary alloc]init];
	formAnnotations = [[NSMutableDictionary alloc]init];
	allPageObjects = [[NSMutableArray alloc]init];
	
	if([self Parse: error] == FALSE) {
		[self unloadFile];
		return FALSE;
	}
	
//	We've read and parsed all of the objects we want to.  Now close the file and release the memory.
		
	myDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef)(filePath));
	
	curPage = -1;
	totalPages = CGPDFDocumentGetNumberOfPages(myDocumentRef);
	return TRUE;
}

//
//	A change was made to the file.  We need to completely unload and reload the file again.
//
-(void) unloadFile
{
	[page PdfPageUnloadPage];
	[allPageObjects release]; allPageObjects= nil;
	[formAnnotations release]; formAnnotations= nil;
	[fieldsByName release]; fieldsByName= nil;
	[offsetTable release]; offsetTable= nil;
	[objectTable release]; objectTable= nil;
	[fd release];
	endOfFile = 0;
	[pdf release];
	CGPDFDocumentRelease(myDocumentRef);
	pdf = nil;
}

// sort the xref entries by offset
static NSInteger offsetSort(XrefEntry *obj1, XrefEntry *obj2, void *junk)
{
	if([obj1 offset] < [obj2 offset]) return NSOrderedAscending;
	if([obj1 offset] > [obj2 offset]) return NSOrderedDescending;
	return NSOrderedSame;
}

//
//	Add this object to the xref table if it is not there already.
//
-(void) addObjectToXref: (int)objectNumber andGeneration: (int) generationNumber andObject: (PdfObject *)pObject andOffset:(int) off
{
	NSString *objNumStr = [NSString stringWithFormat:@"%d", objectNumber];
#if 0
	NSLog(@"%d %d", objectNumber, generationNumber);
	
	NSLog(@"%@", [pObject toString]);
#endif
	//
	//	Since we iterate backwards through potentially multable xref tables, only the first found
	//	instance of an object is recorded as this references the last updated version of this object.
	//
	XrefEntry *alreadyThere;

	if((alreadyThere = [objectTable objectForKey:objNumStr]) == nil) {
		XrefEntry *entry = [[XrefEntry alloc] initWithObjectNumber:objectNumber 
											   andGenerationNumber:generationNumber
														 andOffset:off
														 andActive:TRUE];
		entry.pObj = pObject;
		[objectTable setObject:entry forKey:objNumStr];		// in a dict so we can access by key
		[offsetTable addObject:entry];						// in array so we can sort by offset
	} 
	
	else {
		if(alreadyThere.pObj == nil && alreadyThere.offset == 0)
			alreadyThere.pObj = pObject;
	}


}

-(int) GetPreviousStartXREF: (cstring *)ip fromEnd: (int) end
{
	int startxref = [ip LastIndexOf:"startxref" from:end];
	if(startxref == -1) return -1;
	NSMutableArray *match = [ip MatchWithRegex:STARTXREF_REGEX fromStart:startxref forLength: (end - startxref)];
	if(match)
		return [[ip getSubStringFromRange:[[match objectAtIndex:1] rangeValue]] intValue];
	else {
		return -1;
	}
}
//
//	Walk through an object.  parse the object and place it in the Xref table.
//	if the parsed object is a dictionary (shoiuld be) and the dictionary says this object
//	represents and object stream, then decompress the object stream and add THOSE objects 
//	too.  The parameter to this call is the result of a regex search using OBJECT_REGEX
//	which captures the obj#, the gen#, and the data between obj and endobj.
//
-(void) AddObjectsToXref:(XrefEntry *)hostObject
{
	//	After the search, index 0 =entire object from obj # through endobj, 1 = obj num, 2 = gen #, 3 = object data.
	
	int start = hostObject.offset;
	int end = [self GetEndOfObject:hostObject.objNumber];
	if(end < 0) end = [pdf length];
	cstring *ip = [[cstring alloc]initWithData:pdf andRange:NSMakeRange(start, end-start)];
	PdfObject *thisObj = [self GetPdfObjectFromNumber:hostObject.objNumber];

	NSMutableArray *match = [ip MatchWithRegex: STREAM_REGEX betweenStart: 0 andEnd: [ip length]];
//		Get the data between stream and endstream.
	
	if(match) {
	
		NSRange objRange = [[match objectAtIndex:0]rangeValue];
		objRange.location += start;
		NSData *curObj = [ip.data subdataWithRange:objRange];
		cstring *newObjPtr = [[cstring alloc] initWithData:curObj];
	
		if ([thisObj isKindOfClass:[PdfDictionary class]]) {
			PdfName *type = [(PdfDictionary *)thisObj objectForKey:@"/Type"];
			if([type isEqualToString: @"/ObjStm"]) {
				PdfName *decode = [(PdfDictionary *)thisObj objectForKey:@"/Filter"];
				
// check for Flatedecode
				
				PdfNumber *first = [(PdfDictionary *)thisObj objectForKey:@"/First"];
// do anyting wiht the length?
				
				[newObjPtr trimStart];
				if([newObjPtr StartsWith:"stream"]) {
					[newObjPtr SubString:8];	//"stream + cr LF
					int byteoff = newObjPtr.rp - newObjPtr.start;
					NSRange stmRange = NSMakeRange(byteoff, objRange.length - (byteoff + strlen("endstream")));
					NSData *subObjects = [newObjPtr.data subdataWithRange:stmRange];
					NSData *decodedObject = [subObjects zlibInflate];

					NSRange ObjectPair = NSMakeRange(0, [first intValue]);
					NSRange ObjectData = NSMakeRange(ObjectPair.length, [decodedObject length]-[first intValue]);
					
					cstring *objpair = [[cstring alloc] initWithData:[decodedObject subdataWithRange:ObjectPair]];
					cstring *objectData = [[cstring alloc] initWithData:[decodedObject subdataWithRange:ObjectData]];
					
					NSMutableArray *allStreamObjects = [objpair MatchesWithRegex:OBJECTPAIR_REGEX fromStart:0 forLength:ObjectPair.length];
					
					for(NSMutableArray *omatch in allStreamObjects) {
						int nextObjectNumber = [[objpair getSubStringFromRange:[[omatch objectAtIndex:1] rangeValue]] intValue];
						int nextObjectOffset = [[objpair getSubStringFromRange:[[omatch objectAtIndex:2] rangeValue]] intValue];
						PdfObject *nextObj = [PdfObject GetPdfObject:objectData];
						[self addObjectToXref: nextObjectNumber andGeneration: 0 andObject: nextObj andOffset:-1];

					}
					[objpair release];
					[objectData release];
				}
			}
		}
		[newObjPtr release];
				
	}
	[offsetTable sortUsingFunction:offsetSort context:nil];				// sort the new entries back in.
}

-(void) dumpObjTable {
#if 0
	for(XrefEntry *e in offsetTable) {
		if(e.embeddedObject) 
			NSLog(@"%d, embedded in:%d at offset %d", e.objNumber, e.refObject, e.refIndex);
		else				
			NSLog(@"%d %d %d %@", e.objNumber, e.generationNumber, e.offset, e.pObj);

	}
#endif
}
	
-(BOOL) Parse:(NSError **)error
{
	int startTrailer= 0, startxref; 
	cstring *PDFInput;
	NSMutableArray *match;
	
	if(pdf == nil) {
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:kPDFileLinearizedText forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:kFormationErrorDomain code:kPDFileLinearized userInfo:errorDetail];
		return FALSE;
	}
	
	PDFInput = [[cstring alloc] initWithData:pdf];
	form = nil;
	previous = -1;
	int endposition = [pdf length]-1;
	//
	//	See if there is a /Linerar=1 before the first endobj.  Hack but seems to work.
	//
	//	Process all trailers backwards from the end.
	//

#if 0
	if (match = [PDFInput MatchWithRegex:LINEAR_REGEX betweenStart:14 andEnd:[PDFInput IndexOf:"endobj"]]) 
		isLinearized = TRUE;
#endif
	if (match = [PDFInput MatchWithRegex:OBJECT_REGEX betweenStart:0 andEnd:[PDFInput IndexOf:"endobj"]+10]) {
		NSRange r = [[match objectAtIndex:0] rangeValue];
		PdfDictionary *linearDict = (PdfDictionary *)[self ParseObjectFromHere: r.location toHere: (r.location+ r.length)];
		if((linearDict != nil) && ([linearDict isKindOfClass:[PdfDictionary class]])) {
			int linearval = [(PdfNumber *)[linearDict objectForKey:@"/Linearized"]intValue]; 
			if(linearval > 0) {
#if 0
				isLinearized = TRUE;
				startTrailer = [(PdfNumber *)[linearDict objectForKey:@"/T"]intValue];
#endif
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:kPDFileLinearizedText forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:kFormationErrorDomain code:kPDFileLinearized userInfo:errorDetail];
				return FALSE;
			}
		}
	}

	if((startTrailer == 0) &&(startTrailer = [PDFInput LastIndexOf:"trailer" from:endposition]) >= 0) {
//
//	Old school trailers.  
//
		while(startTrailer >= 0) {
			if(match = [PDFInput MatchWithRegex:TRAIL_REGEX fromStart:startTrailer forLength:(endposition-startTrailer +1)]) {
				NSRange r = [[match objectAtIndex:1] rangeValue];
				trailerString = [PDFInput getSubStringFromRange:r];
			
				cstring *dictInput = [[cstring alloc] initWithString:trailerString];
					
				PdfDictionary *trailerDictionary = [[PdfDictionary alloc] initWithCP:dictInput];
			
				startxref = -1;
			
			// in a hybrid-reference file (PDF 1.5), the trailer doesn't seem to
			// always include a startxref.
			
				NSRange range2 = [[match objectAtIndex:2] rangeValue];
				if(range2.location != NSNotFound) {
					NSString *xrefString = [PDFInput getSubStringFromRange:[[match objectAtIndex:3] rangeValue]];
					startxref = [xrefString intValue];
				}
				if(previous == -1)
					previous = startxref;
				
			// we don't believe the startxref field.
			// it can be bogus due to linearization.
			// we'll keep the "previous" value from above though, since
			// that's what taft@adobe.com says in a 1998 post on comp.text.pdf :-)
			
				startxref = [PDFInput LastIndexOf:"xref" from:startTrailer];
			
			
				if(previousTrailer == nil || isLinearized)
					previousTrailer = trailerDictionary;
			
			
			//			Now convert the start of xref to the beginning of the trailer to NSString
			//			So we can parse out the objects.
			
				[self ParseXRef:PDFInput from:startxref];
#if 0			// hack for now.  need to fix
				if([objectTable count] > 0) {
					XrefEntry *e = [offsetTable objectAtIndex:0];	// get offset of 1st object->new end po
					endposition = e.offset;
				} else {
					endposition = startxref;
				}
#else
				endposition = startxref;
#endif
				[dictInput release];
			}
			startTrailer = [PDFInput LastIndexOf:"trailer" from:endposition];	// get previous trailer.

		}
	} else {
//
//	New school trailer objects.
//
		int lastend = [pdf length];
		newTrailerFormat = TRUE;
//		isLinearized = TRUE;
		
		if(startTrailer > 0)
			startxref = startTrailer;
		else
			startxref = [self GetPreviousStartXREF: PDFInput fromEnd: lastend];
		
		while(startxref >= 0 && (startxref < lastend)) {
		
			PdfNumber *nextXrefOffset = nil;
			PdfDictionary *curTrailer;
			
			//
			// Get the trailer object pointer to by xref.
			//
			NSMutableArray *trailerObject = [PDFInput MatchWithRegex: OBJECT_REGEX betweenStart: startxref andEnd: lastend];

			if(trailerObject == nil) break;

			if(previous == -1)
				previous = startxref;			// needed for writing out trailer

			NSRange tr = [[trailerObject objectAtIndex:3] rangeValue];
			NSData *trailerData = [pdf subdataWithRange:tr];
			cstring *cp = [[cstring alloc]initWithData:trailerData];
	
			curTrailer = [PdfObject GetPdfObject:cp];

			if(previousTrailer == nil)
				previousTrailer = curTrailer;
//
//	The backward pointer to the previous xref object "should" be referenced by /Prev.  If not, look beyond the current
//	xref object for the startxref tag and get that number.
//
			nextXrefOffset =(PdfNumber *)[curTrailer objectForKey:@"/Prev"];
	
			int previous = startxref;
			if( nextXrefOffset != nil)
				startxref = [nextXrefOffset intValue];
			else {
//				startxref = -1;
				startxref = [self GetPreviousStartXREF: PDFInput fromEnd: lastend];

			}
			lastend = previous;
			
			[cp trimStart];
			if(![cp StartsWith:"stream"]) continue;
			[cp SubString:6];
			[cp trimStart];
			
			
			PdfName *type = (PdfName *)[curTrailer objectForKey:@"/Type"];
			if(![type isEqualToString:@"/XRef"]) continue;

			PdfArray *byteCountArray = (PdfArray *)[curTrailer objectForKey:@"/W"];
			PdfArray *indexArray = (PdfArray *)[curTrailer objectForKey:@"/Index"];
			PdfArray *decode = (PdfArray *)[curTrailer objectForKey:@"/Filter"];
			if(indexArray == nil) {		// special case.  default = one entry starting at 0 and going to /Size
				int size = [(PdfNumber *)[curTrailer objectForKey:@"/Size"]intValue];
				indexArray = [[[PdfArray alloc] initWithString:[NSString stringWithFormat:@"0  %d]", size]]autorelease];
			}
			
			char *bp;
			
			NSData *subObjects;
			NSData *decodedObject;
			
			if(decode) {
//				continue;
//#if 0
				NSRange objRange = [[trailerObject objectAtIndex:3]rangeValue];
				int byteoff = cp.rp - cp.start;
				NSRange stmRange = NSMakeRange(byteoff, objRange.length - (byteoff + strlen("endstream")));
				subObjects = [cp.data subdataWithRange:stmRange];
				decodedObject = [subObjects zlibInflate];
				bp = [decodedObject bytes];
				PdfDictionary *decodeParms = (PdfDictionary*)[curTrailer objectForKey:@"/DecodeParms"];
				if(decodeParms != nil) {
					int columns = [(PdfNumber *)[decodeParms objectForKey:@"/Columns"]intValue];
					int predictor = [(PdfNumber *)[decodeParms objectForKey:@"/Predictor"]intValue];
					if(( predictor >= 10) && (predictor <=15)) {
						int rowlength = columns + 1;
						int nrows = [decodedObject length]/rowlength;
						// create blank previous row
						NSData *prevrow = [NSData dataWithBytes:[decodedObject bytes] length:rowlength];
						unsigned char *pcp = [prevrow bytes];
						for(int i=0; i< rowlength; i++)
							pcp[i] = '\0';
						
						NSData *workbuf = [NSData dataWithData:decodedObject];
						unsigned char *outp = (unsigned char *)[workbuf bytes];
						unsigned char *nextscan = (unsigned char *)bp;

						for(int i = 0; i < nrows; i++) {
							unsigned char filterbyte = *nextscan; 
							switch(filterbyte) {
								case 0: 
									break;
								case 1: 
									for(int j=2; j< rowlength; j++) {
										nextscan[j] = (nextscan[j] + nextscan[j-1]) & 0xff;	// added to previous byte;
									}
									break;
								case 2:
									for(int j=1; j< rowlength; j++) {
										nextscan[j] = (nextscan[j] + pcp[j]) & 0xff;
									}
									break;
							}
							for(int j=1;j<rowlength;j++) {
								*outp++ = nextscan[j];
								pcp[j] = nextscan[j];
							}
							nextscan += rowlength;
						}
						bp = [workbuf bytes];
												
					}
				}
						

//#endif
			} else {
				bp = cp.rp;
			}

				
				
			
			if((byteCountArray == nil) || (indexArray == nil))
				continue;
			int wid0 = [(PdfNumber *)[byteCountArray objectAtIndex:0] intValue];	// # bytes for number
			int wid1 = [(PdfNumber *)[byteCountArray objectAtIndex:1] intValue];	// # bytes for offset
			int wid2 = [(PdfNumber *)[byteCountArray objectAtIndex:2] intValue];	// # bytes for generation.
			
			for( int i = 0; i < [indexArray count]; i+= 2) {
				
				int startObj = [(PdfNumber *)[indexArray objectAtIndex:i] intValue];
				int runObj = [(PdfNumber *)[indexArray objectAtIndex:i+1] intValue];
				while(runObj-- > 0) {
					int field1 = 0;
					int field2 = 0; int field3 = 0;
					unsigned char c;
					if (wid0 == 0) {
						field1 = 1;
					} else	{
						for(int j = 0; j < wid0; j++) {
							field1 = field1 * 256;
							c = *bp++;
							field1 += c;
						}
					}
					
					for(int j = 0; j < wid1; j++) {
						field2 = field2 * 256;
						c = *bp++;
						field2 += c;
					}
					for(int j = 0; j < wid2; j++) {
						field3 = field3 * 256;
						c = *bp++;
						field3+= c;
					}
					
					XrefEntry *entry;
	
					switch(field1) {
							
						case 0: 
							startObj++;				// linked list of free objects.. don't care.  next object
							continue;				// 
						case 1:							// offset is offset into the file.  generation has generation #
//
//	format: 01 xxxx yyyy  x = byte offset from beginning of file.  yy == generation
//
							;
							entry = [[XrefEntry alloc] initWithObjectNumber:startObj
																   andGenerationNumber:field3
																			 andOffset:field2
																			 andActive:TRUE];
							break;
						case 2:							// represents offset into another reference object.
//
//	format: 02 xxxx yyyy  x = reference object.  yy == index into reference file.
//
							;
							entry = [[XrefEntry alloc] initWithObjectNumber:startObj		//
																   andGenerationNumber:0
																			 andOffset:0
																			 andActive:TRUE];
							entry.embeddedObject = TRUE;
							entry.refObject = field2;
							entry.refIndex = field3;
							break;
					}
							
					NSString *objNumStr = [NSString stringWithFormat:@"%d", startObj];
					
					//
					//	Since we iterate backwards through potentially multable xref tables, only the first found
					//	instance of an object is recorded as this references the last updated version of this object.
					//
					if([objectTable objectForKey:objNumStr] == nil) {
						[objectTable setObject:entry forKey:objNumStr];		// in a dict so we can access by key
						[offsetTable addObject:entry];						// in array so we can sort by offset
					}
					startObj++;
				}
			}
				
			[cp release];
		}
		[offsetTable sortUsingFunction:offsetSort context:nil];
	}
		
	rootObjectNumber = [(PdfReference *)[previousTrailer objectForKey:@"/Root"] getObjNumber];

	for(XrefEntry *e in offsetTable) {
		if(e.objNumber > lastObject)
			lastObject = e.objNumber;
	}
	lastObject++;
	
//
//	If this is a linearized file,then there are probably object streams (encoded objects).  Start at the beginning,
//	decode them and add them if they don't exist in the table.
//
//#if 0
	[self dumpObjTable];
//#endif
	
//
//	If linearized, there is probably not a full table of contents to work with.  So we need to walk through
//	the file and build it.
//

			

	[self ParseAcroForm];
	
	[self ParsePageTree];
	
	if(form != nil) {

		PdfObject *fieldsObject = [form.fieldDictionary objectForKey:@"/Fields"];
		PdfArray *fieldArray;
		
//
//	Fields is either a reference to an array or an array
//
		if ([fieldsObject isKindOfClass:[PdfArray class]]) 
			fieldArray = (PdfArray *)fieldsObject;	// array

		else if ([fieldsObject isKindOfClass:[PdfReference class]])
			fieldArray = (PdfArray *)[self GetPdfObjectFromReference:(PdfReference *)fieldsObject]; //reference
//
//	Go through the array and pull the field references out.
//
		for(PdfReference *fieldReference in fieldArray) {
//
//	Build out the array of field objects from this reference.
//
			
			NSMutableArray *nextFields = [PdfField GetPdfFields: fieldReference
												  andReader: self
										andParentDictionary: nil
											   andFieldName: @""];
//
//	Now go through all of the fields in the captured array, make sure
//	we have a unique name for each one and then add them to the fields
//	dictionary.
//
			for(PdfField *field in nextFields) {
				//
				//	now make sure we have a unique name.
				//
				NSString *fieldname = field.fieldName;
				int i=0;
				//	look for it, if found, add number and look again till unique.
				while ([fieldsByName objectForKey:fieldname]) {
					fieldname = [NSString stringWithFormat:@"%@%d", field.fieldName, i++];
				}
/*				
				NSLog(@"%@", [field original]);
				NSLog(@"%@", [field toString]);
*/
				[fieldsByName setObject:field forKey:fieldname];
			}
		}
		
//
//	we now have a dictionary full of unique names and fields.
//	We're going to move them into a separate array 
		 for (id theKey in fieldsByName) {
			 PdfField *f = [fieldsByName objectForKey:theKey];  // copy/retain/neither???
			 [fields addObject:f];
//			 NSLog(@"Obj: %d\n%@", f.objectNumber, [f toString]);
		 }
//	print the fields that have been captured in the form array.
		
//		 for(id theKey  in formAnnotations) {
//			 NSLog(@"FORMANNOT: %@", theKey);
//		 }					   
	}			 
			

	[PDFInput release];PDFInput = nil;
	return TRUE;
}

//
//	When we parse the form fields in Pdfform, we will encounter annotation objects that are part of the form.
//	we will record a copy of those annotation objects here.  Later, when we are drawing the page
//	we will cross reference with the form.
//
-(void) addFormAnnotation:(PdfReference *)ref formField:(PdfField *)field
{
	NSString *key = [NSString stringWithFormat:@"%d", ref.objNumber];
	[formAnnotations setObject:field forKey:key];
}

-(id) GetFormAnnotation: (int) objno
{
	return [formAnnotations objectForKey:[NSString stringWithFormat:@"%d", objno]];
}
//
//	add the page object into the array.  The PDF has the pages distributed as a tree.  We call PdfPageTreeNode to parse through them.
//	Eventually they create actual page objects.  Since these are processed in order, we can build up an array of references to these
//	This function is called by the PdfPage init code.
-(void) addPageObject:(PdfPage *)p
{
	[allPageObjects addObject: p];
}
//
//	Xref points at the beginning of an xref run.  Find all of the matches and build the
//	object offset table.  If the object is already in the list then don't add it again.
//	This is the case when the file has been updated and the object has been rev'd
//	We'll always use the first one we find which is the lastone in the file since we go backwards.
//
//	There are two kinds of cross references.  
-(void) ParseXRef: (cstring	*)PDFInput from: (int) startxref
{
	int objectNumber = 0;
	int offset, generationNumber;
//
//	If the text at startxref is "xref" then this is old style.  Otherwise it is probably a xref object.
//
	
	int endOfXref = [PDFInput IndexOf:"trailer" from:startxref+4];
	
	NSMutableArray *refMatches = [PDFInput MatchesWithRegex:REF_REGEX	fromStart:startxref+4 forLength:endOfXref - (startxref + 4) + 1];
	
	for(NSMutableArray *match in refMatches) {
		NSRange range2 = [[match objectAtIndex:2] rangeValue];
		if(range2.location != NSNotFound) {
			objectNumber = [[PDFInput getSubStringFromRange:range2] intValue];
		}
		
		offset = [[PDFInput getSubStringFromRange:[[match objectAtIndex:4] rangeValue]] intValue];	
		generationNumber = [[PDFInput getSubStringFromRange:[[match objectAtIndex:5] rangeValue]] intValue];
		
		if([[PDFInput getSubStringFromRange:[[match objectAtIndex:6] rangeValue]] isEqualToString:@"n"]) {
			XrefEntry *entry = [[XrefEntry alloc] initWithObjectNumber:objectNumber 
												   andGenerationNumber:generationNumber
															 andOffset:offset
															 andActive:TRUE];
			NSString *objNumStr = [NSString stringWithFormat:@"%d", objectNumber];
								   
			//
			//	Since we iterate backwards through potentially multable xref tables, only the first found
			//	instance of an object is recorded as this references the last updated version of this object.
			//
			if([objectTable objectForKey:objNumStr] == nil) {
				[objectTable setObject:entry forKey:objNumStr];		// in a dict so we can access by key
				[offsetTable addObject:entry];						// in array so we can sort by offset
			}
			
			if(objectNumber == 0)
				nullOffset = offset;	// special case: in order to build a new xref we need the
			// first free object number
		}
		objectNumber++;
		lastObject = MAX(lastObject, objectNumber);
	}
	[offsetTable sortUsingFunction:offsetSort context:nil];
}

-(PdfDictionary *)ParseDFDData:(NSString *)dfd
{
	cstring *ip;
	
	ip = [[cstring alloc] initWithString:dfd];
	
	PdfDictionary *formDict = (PdfDictionary *)[self ParseObjectInCstring:ip];
	
//	NSLog(@"%@", [formDict toString]);
	
	[ip release];
	
	return formDict;
}

-(void) ReplaceTextFields:(NSString *)fdf
{
	PdfDictionary *fdfObject = [self ParseDFDData:fdf];
	PdfDictionary *FDF = [fdfObject objectForKey:@"/FDF"];
	
	
	for(NSObject *f in fields) {
		if([f isKindOfClass:[PdfTXField class]]) {
			PdfTXField *tf = (PdfTXField *)f;
			PdfDictionary *pd = [tf fieldDictionary];
			PdfName *oldFieldName = (PdfName *)[pd objectForKey:TName];
			if(oldFieldName) {
				NSString *textName = [oldFieldName toString];
				PdfArray *newFields = [FDF objectForKey:@"/Fields"];
				if(newFields) {
					for(PdfDictionary *d in newFields) {
						PdfString *newFieldName = (PdfString *)[d objectForKey:TName];
						PdfString *newFieldValue = (PdfString *)[d objectForKey:VName];
						if (newFieldName && (![[newFieldValue toString] isEqualToString:@"(null)" ]) && [textName isEqualToString:[newFieldName toString]]) {
							[tf setText:[newFieldValue text]];
							break;
						}
					}
				}
			}
		}
	}
}
		

-(NSString *)CreateDFDData
{
	NSString *rets = @"FDF-1.2\n1 0 obj\n";
	
	rets = [rets stringByAppendingFormat:@"<</FDF<<"];
	
	if([fields count]) {
		rets = [rets stringByAppendingString:@"/Fields["];
		for(PdfField *f in fields) {
			PdfDictionary *d = f.fieldDictionary;
			PdfName *fieldName = (PdfName *)[d objectForKey:TName];
			if(fieldName) {
				rets = [rets stringByAppendingFormat:@"<<"];
				rets = [rets stringByAppendingFormat:@"/T%@", [fieldName toString]];
				PdfName *valueName = (PdfName *)[d objectForKey:VName];
				rets = [rets stringByAppendingFormat:@"/V%@", [valueName toString]];
				rets = [rets stringByAppendingFormat:@">>"];
			}
		}
		rets = [rets stringByAppendingFormat:@"]"];
	}
	rets = [rets stringByAppendingFormat:@"/F(%@)>>>>\nendobj\ntrailer\n<</Root 1 0 R>>\n%%EOF", filePath];

	return rets;
}
		
-(PdfObject *)GetPdfObjectFromNumber: (int)number
{
	XrefEntry *objEntry = [objectTable objectForKey:[NSString stringWithFormat:@"%d", number]];

	if(objEntry) {
		if([objEntry isActive]) {
			if(objEntry.pObj) 
				return objEntry.pObj;	// already parsed.
			
			if(objEntry.embeddedObject == TRUE) {
				XrefEntry *hostObject = [objectTable objectForKey:[NSString stringWithFormat:@"%d",objEntry.refObject]];
				[self AddObjectsToXref:hostObject];			// ok, we've decoded the reference object.
				objEntry.embeddedObject = FALSE;			// Don't look for embedded again 
				return [self GetPdfObjectFromNumber:number];	// try one more time.
			} else{
				int start = [objEntry getOffset];
				int end = [self GetEndOfObject:number];
				return (objEntry.pObj = [self ParseObjectFromHere:start toHere: end]);
			}
		}
		return objEntry.pObj;

	}
	return nil;
}
						   
//
//	return the PdfObject refernced by the reference object
//
-(PdfObject *)GetPdfObjectFromReference: (PdfReference *)reference
{
//	See if this is an active object in the xref table.
	
	return [self GetPdfObjectFromNumber: reference.objNumber];
	
}
//
//	Find the end byte of this object.
//	offsetTable is sorted by the byte offset into the file, not the object number.
//	Alg: search for the matching obj nuumber.  If last obj, return -1
//	else return offset of next object.
//
-(int) GetEndOfObject:(int)objNumber
{

	XrefEntry *objEntry  = nil;
	int i;
	for (i = 0; i < [offsetTable count]; i++) {
		objEntry = [offsetTable objectAtIndex:i];
		if(objEntry.objNumber == objNumber)
			break;
	}
	if (i >= ([offsetTable count] -1))		// If at the end (not found) or last one (no more).
		return -1;
		
	objEntry = [offsetTable objectAtIndex:(i+1)];	// get next one.
		
	return [objEntry offset];
}

-(PdfObject *)ParseObjectInCstring:(cstring *)objInput
{
	NSMutableArray *match;
	if (match = [objInput MatchWithRegex:OBJ_REGEX]) {
			
		NSRange r = [[match objectAtIndex:0] rangeValue];
		
		int endOfMatch = r.location + r.length;
		
		[objInput SubString:endOfMatch];
		return [PdfObject GetPdfObject:objInput];
	}
	return nil;
}	
-(PdfObject *) ParseObjectFromHere: (int) start toHere: (int)end
{
	if(end < 0) 
		end = [pdf length];
	
	
	cstring *objInput = [[cstring alloc] initWithData:pdf andRange:NSMakeRange(start, end-start)];
//
//	Now, match against the Regex to extract the object number, etc.
//
	PdfObject *parsedObject = [self ParseObjectInCstring:(cstring *)objInput];
	
	[objInput release];
	
	return parsedObject;
}

-(NSString *) dumpTable
{
	NSString *rs = [NSString stringWithString:@"\n"];
	for(int i=0; i< [objectTable count]; i++) {
		XrefEntry *e = [objectTable objectForKey:[NSString stringWithFormat:@"%d", i]];
		rs = [rs stringByAppendingFormat:@"(%d) %010d %05d", [e objNumber], [e offset], [e generationNumber]];
		if([e active]) rs = [rs stringByAppendingString:@" n\n"];
		else rs = [rs stringByAppendingString:@" f\n"];
	}
//	NSLog(@"%@",rs);
	return rs;
}

-(NSString *)GetTrailer: (int)xrefOffset
{
	NSMutableDictionary *trailerDictionary =[[NSMutableDictionary alloc]init];

	PdfNumber *root = [previousTrailer objectForKey:@"/Root"];
	PdfNumber *size = [previousTrailer objectForKey:@"/Size"];
	
	[trailerDictionary setObject:[[PdfNumber alloc] initWithString:[NSString stringWithFormat:@"%d", previous]]  forKey:@"/Prev"];
	[trailerDictionary setObject:root  forKey:@"/Root"];
	[trailerDictionary setObject:size  forKey:@"/Size"];

	PdfDictionary *newTrailer = [[PdfDictionary alloc]initWithDictionary:trailerDictionary];
	
	NSString *rets = [NSString stringWithFormat:@"trailer\n%@\nstartxref\n%d\n%%%%EOF\n", [newTrailer toString], xrefOffset];
	
	[trailerDictionary release];
	[newTrailer release];
	return rets;
}

//
//	Get the Xref entry object record given an object number
//
-(XrefEntry *)GetPdfXrefEntryFromNumber: (int)number
{
	return [objectTable objectForKey:[NSString stringWithFormat:@"%d", number]];
}

	
// <summary>
/// Parses the Interactive Form Dictionary referenced by the AcroForm entry in
/// the Document Catalog.
/// </summary>
-(void)ParsePageTree
{
	
	id obj = [self GetPdfObjectFromNumber: rootObjectNumber];
	
	if(!([obj isKindOfClass:[PdfDictionary class]]))
		return;
	
	PdfDictionary *documentCatalogObject = (PdfDictionary *)obj; 
	
	PdfObject *PagesObject = [documentCatalogObject objectForKey:@"/Pages"];
	
	if ([PagesObject isKindOfClass:[PdfReference class]])
	{
		PdfReference *PagesObjectRef = (PdfReference *)PagesObject;
		
		// extract the AcroForm object
		int pagesNumber = PagesObjectRef.objNumber;
		int pagesGeneration = PagesObjectRef.generationNumber;
		PagesObject = [self GetPdfObjectFromNumber:pagesNumber];
		pageTreeNode = [[PdfPageTreeNode alloc]initWithObjno: pagesNumber andGeneration: pagesGeneration andDictionary: (PdfDictionary *)PagesObject andReader:self];

	}
}

/// <summary>
/// Parses the Interactive Form Dictionary referenced by the AcroForm entry in
/// the Document Catalog.
/// </summary>
-(void)ParseAcroForm
{
	
	 id obj = [self GetPdfObjectFromNumber: rootObjectNumber];
	
	if(!([obj isKindOfClass:[PdfDictionary class]]))
		return;
	
	PdfDictionary *documentCatalogObject = (PdfDictionary *)obj; 
	
	PdfObject *acroFormObject = [documentCatalogObject objectForKey:@"/AcroForm"];
	
	if ([acroFormObject isKindOfClass:[PdfReference class]])
	{
		PdfReference *acroFormRef = (PdfReference *)acroFormObject;
		
		// extract the AcroForm object
		int acroNumber = acroFormRef.objNumber;
		int acroGeneration = acroFormRef.generationNumber;
		acroFormObject = [self GetPdfObjectFromNumber:acroNumber];
			
		form = [[PdfAcroForm alloc]initWithObjno: acroNumber andGeneration: acroGeneration andDictionary: (PdfDictionary *)acroFormObject];
	}
}


-(void) ReadDFDFile:(NSURL *)filepath
{}
-(void) WriteDFDFile: (NSURL *)filepath
{}

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

-(void) WritePdf:(NSURL *) url
{
	NSError *error;
	[fd closeFile];

//	replace %%EOF with spaces.
//
	int len = MIN(1024, [pdf length]);
	cstring *ip = [[cstring alloc]initWithData:pdf andRange:NSMakeRange([pdf length]-len, len)];
	NSMutableArray *match;
	if (match = [ip MatchWithRegex:@"\%\%EOF"]) {
		NSRange r = [[match objectAtIndex:0] rangeValue];
		char *cp = [pdf bytes] + ([pdf length] - len) +r.location;
		for(int i=0; i< r.length; i++)
			*cp++ = ' ';		// whiteout the %%EOF
	}
	NSFileHandle *fdout = [NSFileHandle fileHandleForWritingToURL:filePath error:&error];
	[fdout seekToEndOfFile];
	[fdout writeData:changes];
	[fdout closeFile];
}

			
+(CGRect) getPDFRect:(CGPDFArrayRef) rectArray
{
	int arrayCount = CGPDFArrayGetCount( rectArray );
	CGPDFReal coords[4];
		
	for( int k = 0; k < arrayCount; ++k ) {
		CGPDFObjectRef rectObj;
		if(CGPDFArrayGetObject(rectArray, k, &rectObj)) {
			CGPDFReal coord;
			if(CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) 
				coords[k] = coord;
		}
	}
	CGRect rect =  CGRectMake(coords[0], coords[1], coords[2], coords[3]);
	rect.size.width -= rect.origin.x;
	rect.size.height -= rect.origin.y;
	return rect;
}

+(CGRect) getPdfRect:(PdfArray *) rectArray
{
	int arrayCount = [rectArray count];
	
	CGPDFReal coords[4];
	
	for( int k = 0; k < arrayCount; ++k ) {
		PdfNumber *rectObj;
		if(rectObj = [rectArray objectAtIndex:k]) {
			coords[k] = [rectObj floatValue];
		}
	}
	CGRect rect =  CGRectMake(coords[0], coords[1], coords[2], coords[3]);
	rect.size.width -= rect.origin.x;
	rect.size.height -= rect.origin.y;
	return rect;
}

-(PdfPage *) PdfGetPageObject: (int) pageNo
{
	return [allPageObjects objectAtIndex:(pageNo-1)];	// pages start at 1, array at 0.
}	

-(void) saveChanges
{
	[self UpdateAllChanges];
    [self WritePdf:nil];
}

-(void) unloadPage
{
	[page PdfPageUnloadPage];
//	myPageRef = NULL;
//	[page release];
}	
		
-(void) loadPage: (int) pageNo withView:(UIView *)view
{
//
//	Check to see if there is a page loaded and if so, see if updated and if so save it.
//
		
	if(curPage != -1) {
		if([self UpdateAllChanges]) {
			[self WritePdf:nil];
			[self unloadFile];
			[self loadFileWithURL: filePath];
		} else
			[self unloadPage];
	}
		
	myPageRef = CGPDFDocumentGetPage(myDocumentRef, curPage = pageNo);
	page = [self PdfGetPageObject:pageNo]; 
	
	[page PdfPageLoadPage:myPageRef withView: view];
	
}
			
-(void) drawWithContext:(CGContextRef)ctx
{
	if(curPage != -1)
		[page drawWithContext:ctx];
}

-(PdfReference *)CreateNewReference
{
	return [[PdfReference alloc]initWithNumber:lastObject++ andGeneration: 0];
}

-(NSMutableArray *) getFormUpdates
{
	if (form == nil)	// no form
		return nil;
	
	NSMutableArray *updates = [[NSMutableArray alloc]init];

	for(PdfField *field in fields) 
		[updates addObjectsFromArray:[field getUpdate]];
	
	if([updates count] == 0) 
		return nil;		// no form changes.
	
	NSMutableArray *reta = [[[NSMutableArray alloc]init]autorelease];
//
//	Now update the form to a new generation
//
#ifdef BUMPGENERATION
	form.generationNumber++;
#endif
	PdfArray *fieldArray = [form.fieldDictionary objectForKey:@"/Fields"];

	for(int i=0; i< [updates count]; i+= 2) {
		PdfReference *changedRef = [updates objectAtIndex:i];
		for(PdfReference *oldref in fieldArray) {		/* find the obj ref in the form dict /Fields array and update the gen number */
			if(oldref.objNumber == changedRef.objNumber) {
				oldref.generationNumber = changedRef.generationNumber;
				break;
			}
		}
	}
    
    PdfBool *tr = [[[PdfBool alloc]initWithVal:TRUE] autorelease];
    [form.fieldDictionary setObject:tr forKey:@"/NeedAppearances"];
		
	PdfReference *fr = [[PdfReference alloc]initWithNumber:form.objectNumber andGeneration:form.generationNumber];
	[reta addObject:fr];
	[reta addObject:[form toString]];
//
//	Update the Document record to point to the new AcroForm object.
//
	PdfDictionary *docCatalogDict = (PdfDictionary *)[self GetPdfObjectFromNumber: rootObjectNumber];

	[docCatalogDict setObject: fr forKey:@"/AcroForm"];	// replace with new AcroForm generation number.
		
	XrefEntry *e = [self GetPdfXrefEntryFromNumber: rootObjectNumber];
#ifdef BUMPGENERATION		
	PdfReference *dr = [[PdfReference alloc]initWithNumber:rootObjectNumber andGeneration:e.generationNumber+1];
#else
	PdfReference *dr = [[PdfReference alloc]initWithNumber:rootObjectNumber andGeneration:e.generationNumber];
#endif
							
	[reta addObject:dr];
	[reta addObject:[NSString stringWithFormat:@"%d %d obj\n%@\nendobj\n",dr.objNumber, rootGeneration = dr.generationNumber, [docCatalogDict toString]]];
//
//	UPdate the trailer dictionary to reference the new root.
//
	[previousTrailer setObject:dr forKey:@"/Root"];
//
//	Move in al of the changed form objects.
//
	[reta addObjectsFromArray:updates];
	[updates release];

	return reta;
}

-(NSMutableArray *)GetObjectUpdates
{
	NSMutableArray *changedAnnotRefs  = [[[NSMutableArray alloc]init]autorelease];
	[changedAnnotRefs addObjectsFromArray:[page GetChangedAnnots]];	// Get changed annots.  returns alternating pdfref and string.
	[changedAnnotRefs addObjectsFromArray:[page GetNewAnnots]];	// Add any new annotations
	[changedAnnotRefs addObjectsFromArray:[self getFormUpdates]]; // add any forms changed.
	
	return changedAnnotRefs;
}


static NSInteger objSort(XrefEntry *obj1, XrefEntry *obj2, void *junk)
{
	if(obj1.objNumber < obj2.objNumber) return NSOrderedAscending;
	if(obj1.objNumber > obj2.objNumber) return NSOrderedDescending;
	return NSOrderedSame;
}

-(BOOL)UpdateAllChanges
{
	NSMutableArray *allChanges = [self GetObjectUpdates];

	if([allChanges count] <= 0) return NO;	// no changes.
	
	int offset = endOfFile;
	int greatestObjectNumber = -1;
	NSString *update = @"";

	NSString *xref = @"xref\n0 1\n";
	xref = [xref stringByAppendingFormat:@"0000000000 65535 f \n"];
	NSMutableArray *nsindex = [[NSMutableArray alloc]init];
	
	for(int i = 0; i < [allChanges count]; i+= 2) {
		PdfReference *nextObj = [allChanges objectAtIndex:i];
		if(nextObj.objNumber > greatestObjectNumber) greatestObjectNumber = nextObj.objNumber;
		NSString *nextObjString = [allChanges objectAtIndex:(i+1)];
		update = [update stringByAppendingFormat:@"%@",nextObjString];
		xref = [xref stringByAppendingFormat:@"%d 1 \n%010d %05d n \n", nextObj.objNumber, offset, nextObj.generationNumber];
		XrefEntry *e = [[XrefEntry alloc]initWithObjectNumber:nextObj.objNumber 
										  andGenerationNumber: nextObj.generationNumber 
											  andOffset: offset 
											  andActive:TRUE];
		[nsindex addObject:e];
		offset += [nextObjString length];
	}
	

	if(newTrailerFormat == TRUE) {

		PdfName *type = [[PdfName alloc]initWithName:@"/XRef"];
		PdfNumber *prevOff = [[PdfNumber alloc]initWithNumber:[NSNumber numberWithInt:previous]];
		PdfNumber *size = [[PdfNumber alloc]initWithNumber:[NSNumber numberWithInt:greatestObjectNumber+1]];
		PdfReference *root = [[PdfReference alloc] initWithNumber:rootObjectNumber andGeneration:rootGeneration];
		PdfObject *ID = [previousTrailer objectForKey:@"/ID"];
		PdfObject *Info = [previousTrailer objectForKey:@"/Info"];
		PdfReference *newTrailerRef = [self CreateNewReference];
		
		XrefEntry *trailerXref = [[XrefEntry alloc] initWithObjectNumber:  newTrailerRef.objNumber
													 andGenerationNumber: 0
															   andOffset: offset 
															   andActive:TRUE];
		[nsindex addObject:trailerXref];
		nsindex = [nsindex sortedArrayUsingFunction:objSort context:NULL];
		NSMutableArray *indexArray = [[NSMutableArray alloc]init];
		for(XrefEntry *e in nsindex) {
			[indexArray addObject:[[PdfNumber alloc]initWithNumber:[NSNumber numberWithInt:e.objNumber]]];
			[indexArray addObject:[[PdfNumber alloc]initWithNumber:[NSNumber numberWithInt:1]]];
		}
		PdfArray *index = [[PdfArray alloc]initWithArray:indexArray];
		PdfArray *warray = [[PdfArray alloc]initWithString:@"1 4 4]"];
		PdfNumber *length = [[PdfNumber alloc]initWithNumber:[NSNumber numberWithInt:[nsindex count]*9]];
		PdfDictionary *newTrailer = [[PdfDictionary alloc]initWithString:@">>"];
		
		[newTrailer setObject:type forKey:@"/Type"];
		[newTrailer setObject:prevOff forKey:@"/Prev"];
		[newTrailer setObject:size forKey:@"/Size"];
		[newTrailer setObject:root forKey:@"/Root"];
		[newTrailer setObject:ID forKey:@"/ID"];
		[newTrailer setObject:Info forKey:@"/Info"];
		[newTrailer setObject:index forKey:@"/Index"];
		[newTrailer setObject:warray forKey:@"/W"];
		[newTrailer setObject:length forKey:@"/Length"];
		NSString *trailer = [newTrailer toString];
		update = [update stringByAppendingFormat:@"%d 0 obj\n%@stream\n",newTrailerRef.objNumber, trailer];
		
		changes = [update dataUsingEncoding: NSUTF8StringEncoding];
		char xrefstrm[9];
		xrefstrm[0] = '\001';
		for(XrefEntry *e in nsindex) {
			xrefstrm[1] = (e.offset >> 24) & 0xff; 
			xrefstrm[2] = (e.offset >> 16) & 0xff; 
			xrefstrm[3] = (e.offset >> 8) & 0xff; 
			xrefstrm[4] = (e.offset >> 0) & 0xff; 
			xrefstrm[5] = (e.generationNumber >> 24) & 0xff; 
			xrefstrm[6] = (e.generationNumber >> 16) & 0xff; 
			xrefstrm[7] = (e.generationNumber >> 8) & 0xff; 
			xrefstrm[8] = (e.generationNumber >> 0) & 0xff;
			[changes appendBytes:(const void *)xrefstrm length:9];
		}
		NSString *wrapup = [NSString stringWithFormat:@"\nendstream\nendobj\nstartxref\n%d\n%%%%EOF\n",offset];
							
		[changes appendData:[wrapup dataUsingEncoding: NSUTF8StringEncoding]];
		return YES;
			
	} else {
		NSString *trailer = [self GetTrailer:offset];
		update = [update stringByAppendingFormat:@"%@%@",  xref, trailer];
	
//
//	Now write to end of PDF file.
//
//		NSLog(@"CHANGES\n%@", update);
		changes = [update dataUsingEncoding: NSUTF8StringEncoding];
		return YES;
	}

}


#define FONT_REGEX @"^/(\\S+)\\s+(\\d+)"

-(UIFont *)getPdfFont:(PdfDictionary *)d
{

	PdfName *ps = [d objectForKey:@"/DA"];
	NSString  *fontFamily;
	float fontHeight;
	
	if(ps == nil) return nil;
	
	NSString *appearance = [ps text];
	NSError *error;
 	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:FONT_REGEX options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSTextCheckingResult *fontfound = [regex firstMatchInString:appearance options:0 range:NSMakeRange(0,[appearance length])]; 
	if(fontfound) {
		if([fontfound numberOfRanges] > 1) {
			fontFamily = [[appearance substringWithRange:[fontfound rangeAtIndex:1]] retain];
				if([fontFamily isEqualToString:@"Helv"]) fontFamily = @"Helvetica";
				if([fontFamily isEqualToString:@"TiRo"]) fontFamily = @"Times New Roman";
		}
		if([fontfound numberOfRanges] >= 2) {
			fontHeight = [[appearance substringWithRange:[fontfound rangeAtIndex:2]]floatValue];
			if(fontHeight <= 0) fontHeight = 10.0;
//			fontHeight = (fontHeight * 160.0) / 72.0;		// convert point height to pioxel height.
		}
		return [UIFont fontWithName:fontFamily size:fontHeight];
	}
	else
		return [UIFont fontWithName:@"Helvetica" size:11.0];
}

-(void)dealloc
{
	[fields release];
	[fieldsByName release];
	[objectTable release];
	[offsetTable release];
	[formAnnotations release];
	[form release];
	[page release];
	[pdf release];
	[allPageObjects release];
	[super dealloc];
}



@end
