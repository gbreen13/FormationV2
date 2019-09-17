// 
//  PDFFileDescriptor.m
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileManager.h"
#import "PDFFileDescriptor.h"


@implementation PDFFileDescriptor 

@synthesize pDFThumb;
//
//	Create a new entry in the context for this file descriptor.  This is a PDF file and we 
//	need to extract the file name (as screen name), the number of pages and the thumbnailof the first page.
//	We copy the file from the sourceURL to the destination path/name.  path needs to exist though.
//
+ (PDFFileDescriptor *)newPDFFileDescriptorWithSourcePath:(NSString *)sourcePath andDestinationPath:(NSString *)dpath andName:(NSString *)fname err:(NSError **)error
{
	
//
//	Check for path
//
//   NSString* theFileName = [[string lastPathComponent] stringByDeletingPathExtension]      
	
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@.pdf", dpath, [fname stringByDeletingPathExtension]];
	PDFFileDescriptor *newFile;	
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir=YES;
//
//	See if the destination directory is good.
//
	if(![NSFm fileExistsAtPath:dpath isDirectory:&isDir]) {
		NSLog(@"PDFFIleDescriptor: path doesn't exist:%@", dpath);
		return nil;
	}
//
//	See if the source file exists.
//
	isDir = NO;

	if(![NSFm fileExistsAtPath:sourcePath isDirectory:&isDir]) {
		NSLog(@"PDFFIleDescriptor: source file doesn't exist:%@", dpath);
		return nil;
	}
	if(![NSFm fileExistsAtPath:dpath isDirectory:&isDir]) {
		NSLog(@"PDFFIleDescriptor: path doesn't exist:%@", dpath);
		return nil;
	}
	//
//	Attempt to copy the file
//
	if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:fullPathName error:error]) {
		NSLog(@"PDFFIleDescriptor: couldn't copy file:%@", fullPathName);
		return nil;
	}
	
//
//	Now create the core data file descriptor
//
	newFile = [[[PDFFileDescriptor alloc]init]autorelease];
	if(newFile == nil) return nil;
	
	[newFile setScreenName:[fname stringByDeletingPathExtension]];
	[newFile setPath:dpath];
	[newFile setLastModifiedDate:[NSDate date]];
//
//	Use CG/Quartz to create a thumbnail from the first page.
//
	
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:fullPathName]);
	CGPDFPageRef page;
	
	CGRect aRect = CGRectMake(0, 0, 70, 100); // thumbnail size
	UIGraphicsBeginImageContext(aRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage* thumbnailImage;
	
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, aRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
		
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextFillRect(context, aRect);
		
		
		// Grab the first PDF page
	page = CGPDFDocumentGetPage(pdf, 1);
	
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
		// And apply the transform.
	CGContextConcatCTM(context, pdfTransform);
		
	CGContextDrawPDFPage(context, page);
		
		// Create the new UIImage from the context
	thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
		
		//Use thumbnailImage (e.g. drawing, saving it to a file, etc)
		
	CGContextRestoreGState(context);
		
	UIGraphicsEndImageContext();    
	CGPDFDocumentRelease(pdf);	

	NSString *thumbPathName = [NSString stringWithFormat:@"%@/%@.thumb", dpath, [fname stringByDeletingPathExtension]];
	[newFile setPDFThumb:UIImageJPEGRepresentation(thumbnailImage, 1.0)];
    [newFile.pDFThumb writeToFile:thumbPathName atomically:YES];
	
	return newFile;
}

+ (PDFFileDescriptor *) GetPDFFileDescriptorWithPath:(NSString *)dpath andName:fname
{
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@.pdf", dpath, [fname stringByDeletingPathExtension]];
	PDFFileDescriptor* newFile;
    
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir=NO;
	
	if(![NSFm fileExistsAtPath:fullPathName isDirectory:&isDir]) {
		NSLog(@"GetPDFFileDescriptorWithPath: path doesn't exist:%@", fullPathName);
		return nil;
	}
//	newFile = [[[PDFFileDescriptor alloc]init]autorelease];
	newFile = [[PDFFileDescriptor alloc]init];
    
	if(newFile != nil) {
		[newFile setPath: dpath];
		[newFile setScreenName: [fname stringByDeletingPathExtension]];
        NSError *error;
        NSDictionary *att = [NSFm attributesOfItemAtPath:fullPathName error:&error];
 		[newFile setLastModifiedDate: [att objectForKey:NSFileModificationDate]];
//
//  If thumbnail is there, bring it in.
//
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@.thumb", dpath, [fname stringByDeletingPathExtension]];
        NSFileHandle *fd;
        fd = [NSFileHandle fileHandleForReadingAtPath:thumbPath];
        newFile.pDFThumb = [fd readDataToEndOfFile];
	}
	return newFile;    
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path
{
	return YES;
}

-(void) dealloc
{
    [pDFThumb release];
    [super dealloc];
}

@end
