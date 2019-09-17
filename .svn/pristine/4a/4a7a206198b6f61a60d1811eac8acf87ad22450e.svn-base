//
//  FileManager.h
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FolderDescriptor.h"
#import "PortfolioDescriptor.h"
#import "PDFFileDescriptor.h"

#define DOCUMENTS_FOLDER [FileManager applicationDocumentsDirectory]
#define ROOT_FOLDER @"UserRoot"
#define ROOT_PATH [NSString stringWithFormat:@"%@/%@",DOCUMENTS_FOLDER, ROOT_FOLDER]

#define ALLFORMS_FOLDER @"Blank Forms"
#define ALLFORMS_PATH [NSString stringWithFormat:@"%@/%@",ROOT_PATH, ALLFORMS_FOLDER]
#define FORM_DESCRIPTOR @"PDFFileDescriptor"

#define ALLPORTFOLIOS_FOLDER @"Portfolios"
#define ALLPORTFOLIOS_PATH [NSString stringWithFormat:@"%@/%@",ROOT_PATH, ALLPORTFOLIOS_FOLDER]
#define PORTFOLIO_DESCRIPTOR @"PortfolioDescriptor"

#define ALLFOLDERS_FOLDER @"Folders"
#define ALLFOLDERS_PATH [NSString stringWithFormat:@"%@/%@",ROOT_PATH, ALLFOLDERS_FOLDER]
#define FOLDER_DESCRIPTOR @"FolderDescriptor"

#define TMP_FOLDER @"Tmp"
#define TMP_PATH [NSString stringWithFormat:@"%@/%@",ROOT_PATH, TMP_FOLDER]
#define FOLDER_DESCRIPTOR @"FolderDescriptor"
//
//	Directory heirarchy:
//
//	/Documents
//	  /UserRoot									// Root Folder
//		/AllForms								// destination of all downloaded forms
//			form1.pdf							// downloaded form.
//
//		/AllPortfolios							// directory for all portfolios.
//			/portfolioName						//
//				file1.pdf						// file in the portfolio.
//				file2.pdf						// second file in the portfolio.
//		/AllFolders								// directory for all user generated files
//			/folder name						// a user created folder.
//				/file1.pdf						// individual pdf form.
//				/protfolioname.portfolio		// an edited portfolio 
//					file1.pdf
//					file2.odf


@interface FileManager : NSObject {
	FolderDescriptor *rootDesc, *allForms,*allPortfolios, *allFolders, *tmpFolder;
}

@property (nonatomic, retain) FolderDescriptor *rootDesc, *allForms, *allPortfolios, *allFolders, *tmpFolder;

+ (NSString *)applicationDocumentsDirectory;
-(NSString *)GetItemPath: (id)item; 
-(void) initFileFolders;
-(PDFFileDescriptor *)MakeTempPDF:(PDFFileDescriptor *)original;
-(id)GetParent: (id)f;
-(BOOL) copyPDFFileToFolderOrPortfolio:(id)folderOrPortfolio withFile:(PDFFileDescriptor *)f err:(NSError **)error;
-(BOOL) removeItemAtPath:(id)folderOrPortfolioOrFile err:(NSError **)error;
-(BOOL) deleteFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile err:(NSError **)error;  
-(BOOL) addFileToAllForms:(NSURL *)file;
-(BOOL) copyFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to:(FolderDescriptor *)folder err:(NSError **)error;
-(BOOL) renameFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to :(NSString *)newName err:(NSError **)error;
-(BOOL) moveFolderOrPortfolioOrFile: (id)folderOrPortfolioOrFile to:(FolderDescriptor *)folder err:(NSError **)error;

@end

extern FileManager *sharedFileManager;
