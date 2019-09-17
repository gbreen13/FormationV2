//
//  FileManager.m
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileManager.h"

FileManager *sharedFileManager;

@implementation FileManager

@synthesize rootDesc, allForms, allPortfolios, allFolders, tmpFolder;

+ (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

//
//	Demo purposes - copy all of these source files into the working allForms directory.
//

-(BOOL) addFileToAllForms:(NSURL *)file
{
	NSLog(@"%@", file);
    NSError *error;
	NSString *filePath = [file path];
	[[[NSFileManager defaultManager] displayNameAtPath:filePath] stringByDeletingPathExtension];
	if([PDFFileDescriptor newPDFFileDescriptorWithSourcePath:filePath
                                       andDestinationPath:ALLFORMS_PATH 
                                                  andName:[[[NSFileManager defaultManager] 
                                                            displayNameAtPath:filePath] stringByDeletingPathExtension]
                                                      err:&error] == nil)
        return NO;
    return YES;
}

-(void) loadTestData
{
	NSArray *allTestFile = [NSArray arrayWithObjects:
							@"sampleForm1.pdf",
							@"sampleForm2.pdf",
							@"interactiveform_enabled.pdf",
							@"medical_history_09.pdf",
							@"README.pdf",
							@"AnnotList.pdf",
							@"complexform.pdf",
							@"radiobuttontest.pdf",
							@"output.pdf",
							nil];
	
// move test files from the bundle to the directory structure.
	NSError *error;
	for(int i = 0; i < [allTestFile count];  i++) {
		NSString *sourcePath = [[NSBundle mainBundle] resourcePath];
		sourcePath = [sourcePath stringByAppendingPathComponent:[allTestFile objectAtIndex:i]];
		NSString *tmpfile = [NSString stringWithFormat:@"%@/%@", TMP_PATH,[allTestFile objectAtIndex:i]];
		NSData *mainBundleFile = [NSData dataWithContentsOfFile:sourcePath];
		if(mainBundleFile == nil) continue;
		[[NSFileManager defaultManager] createFileAtPath:tmpfile 
												contents:mainBundleFile 
											  attributes:nil];
        [PDFFileDescriptor newPDFFileDescriptorWithSourcePath:tmpfile 
                             andDestinationPath:ALLFORMS_PATH 
									andName:[[NSFileManager defaultManager] displayNameAtPath:sourcePath]
                                                          err:&error];

	}

}

-(void) cleanUpTMP
{
	NSError *error;
	NSString *fullPathName = TMP_PATH;
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	[NSFm setDelegate:self];
	[NSFm removeItemAtPath:fullPathName error:&error];						// remove from directory
	self.tmpFolder = [[FolderDescriptor newFolderDescriptorWithPath: ROOT_PATH
															andName: TMP_FOLDER
                                                                err:&error] retain];
}

-(void) initFileFolders
{
//
//	Create the Core Data constructs.
//
	self.rootDesc = [[FolderDescriptor GetRootDescriptor] retain];
//
//	First time, no root folder.. create them.
//
    NSError *error;
	if(rootDesc == nil) {
		self.rootDesc = [[FolderDescriptor newFolderDescriptorWithPath:DOCUMENTS_FOLDER andName:ROOT_FOLDER
                                                                   err:&error]retain];
		self.allForms = [[FolderDescriptor newFolderDescriptorWithPath:ROOT_PATH
															  andName:ALLFORMS_FOLDER
                                                                   err:&error] retain];
		self.allPortfolios = [[FolderDescriptor newFolderDescriptorWithPath: ROOT_PATH
																   andName: ALLPORTFOLIOS_FOLDER
                                                                        err:&error] retain];
		self.allFolders = [[FolderDescriptor newFolderDescriptorWithPath: ROOT_PATH
																andName: ALLFOLDERS_FOLDER
                                                                     err:&error] retain];
		self.tmpFolder = [[FolderDescriptor newFolderDescriptorWithPath: ROOT_PATH
																 andName: TMP_FOLDER
                                                                    err:&error] retain];
		
#if 0
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		if ([[defaults stringForKey: @"test_mode"] isEqualToString:@"1"])
#endif
			[self loadTestData];
		
	} else {
		self.allForms = [[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFORMS_FOLDER] retain];
		self.allPortfolios = [[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLPORTFOLIOS_FOLDER] retain];
		self.allFolders = [[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] retain];
	}
	[self cleanUpTMP];
}

//
//	Create a temporary file, copy the source file into the file and return the file descriptor.
//
-(PDFFileDescriptor *)MakeTempPDF:(PDFFileDescriptor *)original
{
    NSError *error;
	NSString *sourcePath = [NSString stringWithFormat:@"%@/%@.pdf", [original path], [original screenName]];
	return [PDFFileDescriptor newPDFFileDescriptorWithSourcePath:sourcePath andDestinationPath:TMP_PATH andName:[original screenName] err:&error];
}
//
//	Return the parent descriptor (either PortfolioDescriptor or FolderDescriptor)
//
-(id)GetParent: (FileDescriptor *)f
{
	
	NSString *myPath = [self GetItemPath:f];
	
	NSArray *path = [myPath componentsSeparatedByString:@"/"];
	
	NSString *myName = [path objectAtIndex:([path count]-1)];
	NSString *myParentsName = [path objectAtIndex:([path count]-2)];
	NSString *pathWithoutName = [[f path] substringToIndex:([myPath length] - ([myName length]+[myParentsName length]+2))];	//2 /'/'
	
    if([[myParentsName pathExtension] isEqualToString:@"portfolio"]) {
        return [PortfolioDescriptor GetPortfolioDescriptorWithPath:pathWithoutName andName:myParentsName];
    }
    return [FolderDescriptor GetFolderDescriptorWithPath:pathWithoutName andName:myParentsName];		
}

-(BOOL) copyPDFFileToFolderOrPortfolio:(id)folderOrPortfolio withFile:(PDFFileDescriptor *)f err:(NSError **)error
{
    NSString *destPath;
    destPath = [NSString stringWithFormat:@"%@/%@.pdf",[self GetItemPath:folderOrPortfolio], [f screenName]];
    
//
//  If the file already exists (resave) then blow it away first.
//
    BOOL isDir=YES;
	
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	if([NSFm fileExistsAtPath:destPath isDirectory:&isDir]) {
        [NSFm removeItemAtPath:destPath error:error];						// remove from directory
        destPath = [NSString stringWithFormat:@"%@.thumb", [destPath stringByDeletingPathExtension]];
        [NSFm removeItemAtPath:destPath error:error];
    }
    
    return [self copyFolderOrPortfolioOrFile: (id)f to:(FolderDescriptor *)folderOrPortfolio err:error];
}

				  
//
//  Return the full path name of this entity.  If it is a portfolio, tack on ".portfolio" to the folder name
//
-(NSString *)GetItemPath: (id)item 
{
	if ([item isKindOfClass:[PortfolioDescriptor class]])	// note iskindof class doesn't work.
	   return [NSString stringWithFormat:@"%@/%@", ((FolderDescriptor *)item).path, ((FolderDescriptor *)item).screenName];

	if ([item isKindOfClass:[PDFFileDescriptor class]])	// note iskindof class doesn't work.
        return [NSString stringWithFormat:@"%@/%@.pdf", ((PDFFileDescriptor *)item).path, ((PDFFileDescriptor *)item).screenName];
    
	return [NSString stringWithFormat:@"%@/%@", ((FileDescriptor *)item).path, ((FileDescriptor *)item).screenName];
}
	   
-(BOOL) removeItemAtPath:(id)folderOrPortfolioOrFile err:(NSError **)error
{
	NSString *fullPathName = [self GetItemPath:folderOrPortfolioOrFile];
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	[NSFm setDelegate:self];
    BOOL ret = [NSFm removeItemAtPath:fullPathName error:error];						// remove from directory
    if(ret && [folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]]) {
        fullPathName = [NSString stringWithFormat:@"%@.thumb", [fullPathName stringByDeletingPathExtension]];
        [NSFm removeItemAtPath:fullPathName error:error];
    }
    return ret;
}

-(BOOL) deleteFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile err:(NSError **)error
{
    return [self removeItemAtPath:folderOrPortfolioOrFile err:error];            // remove from the file system
}

-(BOOL) copyFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to:(FolderDescriptor *)folder err:(NSError **)error
{
    NSString *srcPath = [self GetItemPath:folderOrPortfolioOrFile];
    NSString *destPath = [self GetItemPath:folder];
    if([folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]])
        destPath = [NSString stringWithFormat:@"%@/%@.pdf", destPath, [folderOrPortfolioOrFile screenName]];      // dest must contain file name issrc is file.
    else
        destPath = [NSString stringWithFormat:@"%@/%@", destPath, [folderOrPortfolioOrFile screenName]];      // dest must contain file name issrc is file.
  
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	[NSFm setDelegate:self];
    BOOL ret = [NSFm copyItemAtPath:srcPath toPath:destPath error:error];
//  If copy is successful and this is a PDF file, see if there is a thumbnail file too and copy that.
    if(ret == YES && [folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]]) {
        BOOL isDir=NO;
        srcPath = [NSString stringWithFormat:@"%@.thumb", [srcPath stringByDeletingPathExtension]];
        destPath = [NSString stringWithFormat:@"%@.thumb", [destPath stringByDeletingPathExtension]];
       if([NSFm fileExistsAtPath:srcPath isDirectory:&isDir]) {
            [NSFm copyItemAtPath:srcPath toPath:destPath error:nil];
        }
    }
    else
        NSLog(@"%@",[*error userInfo]);
    return ret;
}

-(BOOL) moveFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to:(FolderDescriptor *)folder err:(NSError **)error
{
    NSString *srcPath = [self GetItemPath:folderOrPortfolioOrFile];
    NSString *destPath = [self GetItemPath:folder];
    if([folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]])
        destPath = [NSString stringWithFormat:@"%@/%@.pdf", destPath, [folderOrPortfolioOrFile screenName]];      // dest must contain file name issrc is file.
    else
        destPath = [NSString stringWithFormat:@"%@/%@", destPath, [folderOrPortfolioOrFile screenName]];      // dest must contain file name issrc is file.
    
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	[NSFm setDelegate:self];
    BOOL ret = [NSFm moveItemAtPath:srcPath toPath:destPath error:error];
    if(ret == YES && [folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]]) {
        BOOL isDir=NO;
        srcPath = [NSString stringWithFormat:@"%@.thumb", [srcPath stringByDeletingPathExtension]];
        destPath = [NSString stringWithFormat:@"%@.thumb", [destPath stringByDeletingPathExtension]];
        if([NSFm fileExistsAtPath:srcPath isDirectory:&isDir]) {
            [NSFm moveItemAtPath:srcPath toPath:destPath error:nil];
        }
    }
    return ret;
}

-(BOOL) renameFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to :(NSString *)newName err:(NSError **)error
                                                                                                               
{
    NSString *srcPath = [self GetItemPath:folderOrPortfolioOrFile];
    NSString *destPath;
    if([folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]])
        destPath = [NSString stringWithFormat:@"%@/%@.pdf",((FolderDescriptor *)folderOrPortfolioOrFile).path, [newName stringByDeletingPathExtension]];
    else     if([folderOrPortfolioOrFile isKindOfClass:[PortfolioDescriptor class]])
        destPath = [NSString stringWithFormat:@"%@/%@.portfolio",((PortfolioDescriptor *)folderOrPortfolioOrFile).path, [newName stringByDeletingPathExtension]];
    else
        destPath = [NSString stringWithFormat:@"%@/%@",((FolderDescriptor *)folderOrPortfolioOrFile).path, newName];     // dest must contain file name issrc is file    

	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	[NSFm setDelegate:self];
    BOOL ret = [NSFm moveItemAtPath:srcPath toPath:destPath error:error];
    if(ret == YES && [folderOrPortfolioOrFile isKindOfClass:[PDFFileDescriptor class]]) {
        BOOL isDir=NO;
        srcPath = [NSString stringWithFormat:@"%@.thumb", [srcPath stringByDeletingPathExtension]];
        destPath = [NSString stringWithFormat:@"%@.thumb", [destPath stringByDeletingPathExtension]];
        if([NSFm fileExistsAtPath:srcPath isDirectory:&isDir]) {
            [NSFm moveItemAtPath:srcPath toPath:destPath error:nil];
        }
    }
    return ret;
}

- (void)dealloc {
	[rootDesc release];
	[allForms release];
	[allFolders release];
	[allPortfolios release];
    [super dealloc];
}


@end
