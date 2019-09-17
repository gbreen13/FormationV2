    //
//  PDFViewController.m
//  Formation
//
//  Created by George Breen on 1/12/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PDFViewController.h"
#import "PdfReader.h"


PdfReader *sharedPdfReader;

@implementation PDFViewController
@synthesize reader, saveButton, prevButton, nextButton, curURL, fileLabel;
@synthesize delegate = _delegate;

- (void) releaseFile {
	[myContentView release], myContentView = nil;
	[sharedPdfReader release], sharedPdfReader = nil;
}

- (void)dealloc
{
	if(fileIsLoaded) [self releaseFile];
    [super dealloc];
}


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

-(BOOL) PdfLoadFile:(NSURL *)filePathURL error:(NSError **)error
{
	if(fileIsLoaded) 
		[self releaseFile];

	if(sharedPdfReader == nil)
		sharedPdfReader = [[PdfReader alloc]init];
	
	if([sharedPdfReader loadFileWithURL:filePathURL error:error] == FALSE) {
		return FALSE;
	}
	curURL = filePathURL;
	return TRUE;
}

-(void) ReplaceTextFields:(NSString *) DFDfile
{
	[sharedPdfReader ReplaceTextFields:DFDfile];
}
	 

-(IBAction) PdfSetNextPage: (id)sender
{
	int page = [sharedPdfReader curPage];
	if(page < ([sharedPdfReader totalPages])) {
		[sharedPdfReader  loadPage:++page withView:pageView];
	}
	[prevButton setEnabled:TRUE];
	if(page == [sharedPdfReader totalPages])
		[nextButton setEnabled:FALSE];
	pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", page, [sharedPdfReader totalPages]];
}

-(IBAction) PdfSetPrevPage: (id) sender
{
	int page = [sharedPdfReader curPage];
	if(page > 1) {
		[sharedPdfReader  loadPage:--page withView:pageView];
	}
	if(page == 1)
		[prevButton setEnabled:FALSE];
	if([sharedPdfReader totalPages] > 1)
		[nextButton setEnabled:TRUE];
	
	pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", page, [sharedPdfReader totalPages]];
					  
}

-(IBAction) Cancel: (id) sender
{
    if(_delegate != nil) {
        [_delegate PDFdidFinishWithResult:PDFViewResultCancelled object:nil];
    }
	[self releaseFile];
}

-(void) SaveQuietly
{
 	[sharedPdfReader saveChanges];
	[self releaseFile];
}

-(IBAction) Save: (id) sender
{
 	[sharedPdfReader saveChanges];
	NSString *work = [sharedPdfReader CreateDFDData];
    
    if(_delegate != nil) {
         [_delegate PDFdidFinishWithResult:PDFViewResultSave object:work];
    }
	[self releaseFile];
#if 0
	[sharedPdfReader saveTest];
	NSLog(@"%@",work);
	PdfDictionary *work2 = [sharedPdfReader ParseDFDData:work];
	NSLog(@"%@",[work2 toString]);
#endif
}

-(void) viewWillAppear:(BOOL)animated
{
	
    [super viewWillAppear:animated];
	[sharedPdfReader  loadPage:1 withView:pageView];
	
	[prevButton setEnabled:FALSE];
	if([sharedPdfReader totalPages] == 1)
		[nextButton setEnabled:FALSE];
	pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", 1, [sharedPdfReader totalPages]];
	NSArray *paths = [[curURL absoluteString]componentsSeparatedByString:@"/"];
	fileLabel.text = [paths objectAtIndex:[paths count]-1];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	viewIsLoaded = YES;
}



-(int) getCurrentPage
{
	return [sharedPdfReader curPage];
}

@end
