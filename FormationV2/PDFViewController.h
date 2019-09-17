//
//  PDFViewController.h
//  Formation
//
//  Created by George Breen on 1/12/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfReader.h"

enum PDFViewResult {
    PDFViewResultCancelled,
    PDFViewResultSave,
    PDFViewResultError
};
    
typedef enum PDFViewResult PDFViewResult;  

@protocol PDFViewDelegate
-(void)PDFdidFinishWithResult: (PDFViewResult)result object:(NSString *)DFDData;
@end
@interface PDFViewController : UIViewController   {
	UIView *myContentView;
	NSURL *fileURL;
	BOOL viewIsLoaded;
	BOOL fileIsLoaded;
	PdfReader *reader;
	NSURL *curURL;
	IBOutlet UIView *pageView;
	IBOutlet UILabel *fileLabel, *pageLabel;
	IBOutlet UIBarButtonItem *saveButton, *prevButton, *nextButton, *cancelButton;
	id<PDFViewDelegate> _delegate;
}

-(void) releaseFile;
-(int) PdfGetTotalPages;
-(void) PdfSetCurrentPage:(int) pageNo;
-(int) PdfGetCurrentPage;
-(BOOL) PdfLoadFile: (NSURL *)filePath error:(NSError **)error;
-(IBAction) PdfSetNextPage: (id)sender;
-(IBAction) PdfSetPrevPage: (id) sender;
-(IBAction) Save: (id) sender;
-(IBAction) Cancel: (id) sender;
-(void) SaveQuietly;
-(void) ReplaceTextFields:(NSString *) DFDfile;
@property (nonatomic, assign) PdfReader * reader;
@property (nonatomic, assign) UIBarButtonItem *saveButton, *prevButton, *nextButton, *cancelButton;
@property (nonatomic, assign) UILabel *fileLabel, *pageLabel;
@property (nonatomic, assign) NSURL *curURL;
@property (nonatomic, retain) id<PDFViewDelegate> delegate;

@end

