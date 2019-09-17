//
//  PDFFileDescriptor.h
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileDescriptor.h"
@interface PDFFileDescriptor :  FileDescriptor  
{
    NSData *pDFThumb;
}

@property (nonatomic, retain) NSData * pDFThumb;


+ (PDFFileDescriptor *)newPDFFileDescriptorWithSourcePath:(NSString *)sourcePath andDestinationPath:(NSString *)ppath andName:(NSString *)fname err:(NSError **)error;
+ (PDFFileDescriptor *) GetPDFFileDescriptorWithPath:(NSString *)dpath andName:fname;

@end



