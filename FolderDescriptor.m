// 
//  FolderDescriptor.m
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileManager.h"
#import "FolderDescriptor.h"


@implementation FolderDescriptor 


+ (id) newFolderDescriptorWithPath:(NSString *)dpath andName:(NSString *)fname err:(NSError **)error
{
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@", dpath, fname];
	FolderDescriptor* newFolder;
	
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir=YES;
	
	if(![NSFm fileExistsAtPath:dpath isDirectory:&isDir]) {
		NSLog(@"newFolder: path doesn't exist:%@", dpath);
		return nil;
	}
    
	if(![NSFm createDirectoryAtPath:fullPathName withIntermediateDirectories:NO attributes:nil error:error]) {
		isDir = YES;
		if(![NSFm fileExistsAtPath:fullPathName isDirectory:&isDir]) {		// couldn't create.  If there, is ok.  i think.
			NSLog(@"newFolder: directory create failed:%@", fullPathName);
			return nil;
		}
		newFolder = [FolderDescriptor GetFolderDescriptorWithPath:dpath andName:fname];
		if(!newFolder) {
			NSLog(@"newFolder: directory create failed:%@", fullPathName);
			return nil;
		}
		NSLog(@"newFolder: directory already exists:%@", fullPathName);
		return newFolder;
	}
	
	newFolder = [[FolderDescriptor alloc]init];

	if(newFolder != nil) {
		[newFolder setPath: dpath];
		[newFolder setScreenName: fname];
		[newFolder setLastModifiedDate: [NSDate date]];
	}
	return newFolder;
}

+ (FolderDescriptor *) GetFolderDescriptorWithPath:(NSString *)dpath andName:fname 
{
	NSString *fullPathName = [NSString stringWithFormat:@"%@/%@", dpath, fname];
	FolderDescriptor* newFolder;
    
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	BOOL isDir=YES;
	
	if(![NSFm fileExistsAtPath:fullPathName isDirectory:&isDir]  ||  !isDir) {
		NSLog(@"GetFolderDescriptorWithPath: path doesn't exist:%@", dpath);
		return nil;
	}
	newFolder = [[FolderDescriptor alloc]init];
    
	if(newFolder != nil) {
		[newFolder setPath: dpath];
		[newFolder setScreenName: [fname stringByDeletingPathExtension]];
        NSError *error;
        NSDictionary *att = [NSFm attributesOfItemAtPath:fullPathName error:&error];
 		[newFolder setLastModifiedDate: [att objectForKey:NSFileModificationDate]];
	}
	return newFolder;
}

//
//	get subfolders sorted by name
//
-(NSArray *) GetSubfolders
{
	NSFileManager *NSFm= [NSFileManager defaultManager];
    NSString *fullPath = [sharedFileManager GetItemPath: self];
    NSArray *contents = [NSFm contentsOfDirectoryAtPath:fullPath error:nil];
    
    NSMutableArray *reta = [[NSMutableArray alloc]init];
    
    for (NSString *str in contents) {
        BOOL isDir;
        if([NSFm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", fullPath, str] isDirectory:&isDir]  && !isDir)  // only looking for folders.
            continue;
        if([[str pathExtension] isEqualToString:@"portfolio"]) // not interested in portfolios
            continue;
        
        FolderDescriptor *pdfFile = [FolderDescriptor GetFolderDescriptorWithPath:fullPath andName:[str lastPathComponent]];
        [reta addObject:pdfFile];
    }
    
	return [(NSArray *) reta autorelease];
}


//
//	Get porfolios sorted by name
//
-(NSArray *) GetPortfolios
{
	NSFileManager *NSFm= [NSFileManager defaultManager];
    NSString *fullPath = [sharedFileManager GetItemPath: self];
    NSArray *contents = [NSFm contentsOfDirectoryAtPath:fullPath error:nil];
    
    NSMutableArray *reta = [[NSMutableArray alloc]init];
    
    for (NSString *str in contents) {
        BOOL isDir;
        if([NSFm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", fullPath, str] isDirectory:&isDir]  && !isDir)  // only looking for folders.
            continue;
        if(![[str pathExtension] isEqualToString:@"portfolio"]) // skip the thumbnail file if its there.
            continue;
        
        PortfolioDescriptor *pdfFile = [PortfolioDescriptor GetPortfolioDescriptorWithPath:fullPath andName:[str lastPathComponent]];
        [reta addObject:pdfFile];
    }
    
	return [(NSArray *) reta autorelease];
}

-(NSArray *) GetFiles
{
	NSFileManager *NSFm= [NSFileManager defaultManager];
    NSString *fullPath = [sharedFileManager GetItemPath: self];
    NSArray *contents = [NSFm contentsOfDirectoryAtPath:fullPath error:nil];
 
    NSMutableArray *reta = [[NSMutableArray alloc]init];
    
    for (NSString *str in contents) {
        BOOL isDir;
        if([NSFm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", fullPath, str] isDirectory:&isDir] && isDir)  // only looking for files.
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
    return [[self GetSubfolders]count] + [[self GetPortfolios] count] + [[self GetFiles] count];
}

-(NSArray *) GetContents
{
    
    NSArray *a1 = [self GetSubfolders];
    NSArray *a2 = [self GetPortfolios];
    NSArray *a3 = [self GetFiles];
    
    NSMutableArray *reta = [[NSMutableArray alloc]init];
	[reta addObjectsFromArray:a1];
	[reta addObjectsFromArray:a2];
	[reta addObjectsFromArray:a3];
    return (NSArray *) reta;
}

+ (FolderDescriptor *) GetRootDescriptor
{
	return [FolderDescriptor GetFolderDescriptorWithPath:DOCUMENTS_FOLDER andName:ROOT_FOLDER];
}
	
@end
