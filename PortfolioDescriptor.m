// 
//  PortfolioDescriptor.m
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileManager.h"
#import "PortfolioDescriptor.h"


@implementation PortfolioDescriptor 


+ (PortfolioDescriptor *) newPortfolioDescriptorWithPath:(NSString *)dpath andName:(NSString *)fname err:(NSError **)error
{
    NSString *cleanFname = [NSString stringWithFormat:@"%@.portfolio", [fname stringByDeletingPathExtension]];
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@", dpath, cleanFname];
	PortfolioDescriptor * newPortfolio;
	
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir=YES;

	if(![NSFm fileExistsAtPath:dpath isDirectory:&isDir]) {
		NSLog(@"newPortfolio: path doesn't exist:%@", dpath);
		return nil;
	}
			
	if(![NSFm createDirectoryAtPath:fullPathName withIntermediateDirectories:NO attributes:nil error:error]) {
		isDir = YES;
		if(![NSFm fileExistsAtPath:fullPathName isDirectory:&isDir]) {		// couldn't create.  If there, is ok.  i think.
			NSLog(@"newPortfolio: directory create failed:%@", fullPathName);
			return nil;
		}
		if(![PortfolioDescriptor GetPortfolioDescriptorWithPath:dpath andName:fname]) {
			NSLog(@"newPortfolio: directory create failed:%@", fullPathName);
			return nil;
		}
		NSLog(@"newPortfolio: directory already exists:%@", fullPathName);
		return nil;
	}
	
	newPortfolio = [[PortfolioDescriptor alloc]init];

	if(newPortfolio != nil) {
		[newPortfolio setScreenName:cleanFname];
		[newPortfolio setPath:dpath];
		[newPortfolio setLastModifiedDate:[NSDate date]];
	}
	return newPortfolio;
}
//
//	Return the portfolio descriptor of an existing portfolio.
//
+ (PortfolioDescriptor *) GetPortfolioDescriptorWithPath:(NSString *)dpath andName:fname
{
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@", dpath, fname];
	PortfolioDescriptor* newPortfolio;
    
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir;
	
	if(![NSFm fileExistsAtPath:fullPathName isDirectory:&isDir] || !isDir) {
		NSLog(@"GetportfoliorDescriptorWithPath: path doesn't exist:%@", fullPathName);
		return nil;
	}
	newPortfolio = [[PortfolioDescriptor alloc]init];
    
	if(newPortfolio != nil) {
		[newPortfolio setPath: dpath];
		[newPortfolio setScreenName: fname];
        NSError *error;
        NSDictionary *att = [NSFm attributesOfItemAtPath:fullPathName error:&error];
 		[newPortfolio setLastModifiedDate: [att objectForKey:NSFileModificationDate]];
	}
	return newPortfolio;
}

-(NSArray *) GetPortfolioFiles
{
	NSFileManager *NSFm= [NSFileManager defaultManager];
    NSString *fullPath = [sharedFileManager GetItemPath: self];
    NSArray *contents = [NSFm contentsOfDirectoryAtPath:fullPath error:nil];
    
    NSMutableArray *reta = [[NSMutableArray alloc]init];
    
    for (NSString *str in contents) {
        BOOL isDir;
        if([NSFm fileExistsAtPath:str isDirectory:&isDir] && isDir)  // only looking for files.
            continue;
        if(![[str pathExtension] isEqualToString:@"pdf"]) // skip non pdf files
            continue;
        
        PDFFileDescriptor *pdfFile = [PDFFileDescriptor GetPDFFileDescriptorWithPath:fullPath andName:[str lastPathComponent]];
        [reta addObject:pdfFile];
    }
    
	return [(NSArray *) reta autorelease];
}

-(int) GetContentCount
{
    return [[self GetPortfolioFiles] count];
}

// remove the portfolio from CORE data and the directory heirarchy.

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path
{
	return YES;
}

-(BOOL) DeletePortfolioAndFiles: (NSError **)error
{
    return [sharedFileManager deleteFolderOrPortfolioOrFile:self err:error];
}

	
@end
