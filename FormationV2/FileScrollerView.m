//
//  FileScrollerViewController.m
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileScrollerView.h"


@implementation FileScrollerView


@synthesize addFolderButton, deleteButton, emailButton, copyButton, moveButton, fileTable0, fileTable1, onScreen, offScreen;
@synthesize rootFolder, curFolder, portfolioName, backButton, bb;
@synthesize currentPDF, tmpPDF, pdfViewController, folderOrPortfolioFlag, DFDresult, saveMode;

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.


/*
- (void)loadView
{
    onScreen
}

 */ 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
// Get rid of the root

-(void) resetTablePosition
{
    [self scrollBarOff:NO];
    onScreen = fileTable0; offScreen = fileTable1;
    CGRect r = fileTable0.frame;
    r.origin.x = 0;
    fileTable0.frame = r;
    r.origin.x = r.size.width;  // put tables next to each other
    fileTable1.frame = r;
}

-(void) initTable
{
    buttonBarOn = YES;
   fileTable0.delegate = fileTable0;
    fileTable0.dataSource = fileTable0;
    fileTable1.delegate = fileTable1;
    fileTable1.dataSource = fileTable1;
    [self resetTablePosition];
    [self editOn];
	portfolioName = [[PortfolioNameController alloc] initWithNibName:@"PortfolioName" bundle:nil];
    portfolioName.delegate = self;
    UIImage *buttonImage = [UIImage imageNamed:@"backButton.png"];
    bb = [UIButton buttonWithType:UIButtonTypeCustom];
    [bb setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    bb.font = [UIFont boldSystemFontOfSize:12];
    bb.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [bb addTarget:self action:@selector(backButtonSelected) 
            forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] 
                                 initWithCustomView:bb];
}
    

-(void) scrollBarOff: (BOOL) animated
{
    
    if (buttonBarOn) {
        if(animated) {
            [UIView beginAnimations:@"ScrollOnanimation" context:NULL];
            [UIView setAnimationDuration:.3];
        }
        CGRect r = buttonBar.frame;
        r.origin.y -= kBarHeight;
        buttonBar.frame = r;
        r = tableViewport.frame;
        r.origin.y -= kBarHeight;
        r.size.height += kBarHeight;
        tableViewport.frame = r;
        buttonBarOn = NO;
        if(animated) {
            [UIView commitAnimations];
        }
    }
}

-(void) scrollBarOn: (BOOL) animated
{
    
    if (buttonBarOn == NO) {
        if(animated) {
            [UIView beginAnimations:@"ScrollOnanimation" context:NULL];
            [UIView setAnimationDuration:.3];
        }        CGRect r = buttonBar.frame;
        r.origin.y += kBarHeight;
        buttonBar.frame = r;
        r = tableViewport.frame;
        r.origin.y += kBarHeight;
        r.size.height -= kBarHeight;
        tableViewport.frame = r;
        buttonBarOn = YES;
        if(animated) {
            [UIView commitAnimations];
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark Button Actions methods
////
////    Delete selections
////
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSError *error;
	if([[alert title] isEqualToString:@"Delete"]) {
		if(buttonIndex==0) {
            NSMutableArray *reta = [onScreen getSelected];
            
            for(NSManagedObject *next in reta) {
                [sharedFileManager deleteFolderOrPortfolioOrFile: next err:&error];
             }
            [self doneButtonSelected];
           [onScreen resetList];
        }
	}
    else if([[alert title] isEqualToString:@"Portfolio Alert"]) {
		PortfolioDescriptor * parent = [sharedFileManager GetParent: (PDFFileDescriptor *)currentPDF];
		if(buttonIndex==0) {
			[self replicateFieldsfromPDF:currentPDF fromPortfolio:(PortfolioDescriptor *)parent toPortfolio:(PortfolioDescriptor *)parent];
		}
#if 0
        [sharedFileManager copyPDFFileToFolderOrPortfolio:parent withFile:tmpPDF err:&error];	// make a new copy
        [currentPDF setLastModifiedDate:[NSDate date]];				// update modification date.
#endif
        [sharedFileManager removeItemAtPath:tmpPDF err:&error];		[sharedFileManager removeItemAtPath:tmpPDF err:&error];
		[tmpPDF release];

        [onScreen resetList];
    }
    else if([[alert title] isEqualToString:@"File Save"]) {
        FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
        FolderBrowser *f = [[FolderBrowser alloc] initWithNibName:@"FolderBrowser" bundle:nil mode:kFolderBrowserSaveNewBlankFormMode target:self root:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] blocked:nil];
        [fapp.viewController presentModalViewController:f animated:YES];
        [f release];
    }
    
    else if([[alert title] isEqualToString:@"Portfolio Save"]) {
        FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
        FolderBrowser *f2 = [[FolderBrowser alloc] initWithNibName:@"FolderBrowser" bundle:nil mode:kFolderBrowserSaveNewBlankPortfolioMode  target:self root:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] blocked:nil];
        [fapp.viewController presentModalViewController:f2 animated:YES];
        [f2 release];
    }
}

//
//	this is the whole reason for this application.  replicate all of the matching fields from this PDF to all of the other PDFs in the portfolio.
//
-(void) replicateFieldsfromPDF:(PDFFileDescriptor *)pdf fromPortfolio:(PortfolioDescriptor *)oldPortfolio toPortfolio:(PortfolioDescriptor *)newPortfolio
{
    //
    //	currentPDF contains the updated PDF within a portfolio.  Ask if the user wants to replicate the fields in the other forms in the portfolio.
    //	If so, go through the portfolio and force feed the DFDOut into them.
    //
	NSString *destPath =[NSString stringWithFormat:@"%@/%@%",[newPortfolio path],[newPortfolio screenName]];
    NSError *error;
	NSArray *portfolioFiles = [oldPortfolio GetPortfolioFiles];
	
	for(PDFFileDescriptor *nextFile in portfolioFiles) {
		if([nextFile.screenName isEqualToString:pdf.screenName])		// skip ourselves.
			continue;
        
		PDFFileDescriptor *tmp = [sharedFileManager MakeTempPDF:nextFile];
        
		PDFViewController *NewpdfViewController = [[PDFViewController alloc] initWithNibName:@"PDFViewController" bundle:nil];
		
		NSString *filePath = [NSString stringWithFormat:@"%@/%@.pdf", tmp.path, tmp.screenName];
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
		NewpdfViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		if([NewpdfViewController PdfLoadFile:fileURL error:&error] == FALSE) {
			UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Error replicating fields" 
                                                                message: [error localizedDescription]
                                                               delegate: self cancelButtonTitle: @"Ok" 
                                                      otherButtonTitles: nil];
            
			[someError show];
			[someError release];
		}
		else {
            
			[NewpdfViewController ReplaceTextFields:DFDresult];				// replace the text fields.
			[NewpdfViewController SaveQuietly];
		}
        //
        //	If the file already exists in the destination directory (this is the case when saving back to oneself) remove the old file.
        //
		if(oldPortfolio == newPortfolio) {
            [sharedFileManager deleteFolderOrPortfolioOrFile: nextFile err:&error];
		}
        //
        //	Put tmp file into the portfolio
        //
		NSString *sourcePath = [NSString stringWithFormat:@"%@/%@.pdf", [tmp path], [tmp screenName]];
		[PDFFileDescriptor newPDFFileDescriptorWithSourcePath:sourcePath andDestinationPath:destPath andName:[tmp screenName] err:&error];
		[sharedFileManager removeItemAtPath:tmp err:&error];
		[NewpdfViewController release];
	}
}


-(void) deleteSelected
{
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Delete"];
    [dialog setMessage:@"Are you sure you want to delete all selected items and their subdirectories?"];
    [dialog addButtonWithTitle:@"Yes"];
    [dialog addButtonWithTitle:@"No"];
    [dialog show];
    [dialog release];
}
////
////    Email selections
////
-(void) addAttachment: (id)obj to:(MFMailComposeViewController *)picker
{
	if([obj isKindOfClass:[PortfolioDescriptor class]]) {
		NSLog(@"portfolio: %@/%@", [(PortfolioDescriptor *)obj path], [(PortfolioDescriptor *)obj screenName]);
		NSArray *files = [(PortfolioDescriptor *)obj GetPortfolioFiles];
		for(PDFFileDescriptor *pf in files) {
			[self addAttachment:pf to:picker];
		}
	}
    
	else if ([obj isKindOfClass:[FolderDescriptor class]])	 {
		NSLog(@"folder: %@/%@", [(FolderDescriptor *)obj path], [(FolderDescriptor *)obj screenName]);
		NSArray *f = [(FolderDescriptor *)obj GetSubfolders];
		for(FolderDescriptor *pf in f) {
			[self addAttachment:pf to:picker];
		}
		f = [(FolderDescriptor *)obj GetPortfolios];
		for(FolderDescriptor *pf in f) {
			[self addAttachment:pf to:picker];
		}
		f = [(FolderDescriptor *)obj GetFiles];
		for(FolderDescriptor *pf in f) {
			[self addAttachment:pf to:picker];
		}
	} else {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@.pdf", [(PDFFileDescriptor *)obj path], [(PDFFileDescriptor *)obj screenName]];
        NSLog(@"path: %@",fullPath);
        NSData *myData = [NSData dataWithContentsOfFile:fullPath];
        [picker addAttachmentData:myData mimeType:@"application/pdf" fileName:[(PDFFileDescriptor *)obj screenName]];
    }
}

-(void) emailSelected
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Formation PDF Forms"];
    
    NSMutableArray *reta = [onScreen getSelected];
    NSLog(@"number of selected: %d", [reta count]);
    for(NSManagedObject *obj in reta) {
        [self addAttachment:obj to:picker];
    }
    NSString *emailBody = @"This email contains PDF files sent from the Formation application.  The annotations and completed form fields in the included attachments can be viewed and printed with Adobe reader on the computer.  To view the annotations and completed form fields on the iPAD please use a compatible application like Formation.";
    [picker setMessageBody:emailBody isHTML:NO];
    
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController presentModalViewController:picker animated:YES];
    [picker release];
}
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController dismissModalViewControllerAnimated:YES];
    [self doneButtonSelected];
}


-(void)FolderBrowserOKEntered: (FolderDescriptor *)folder mode:(int)browsermode
{
    // copy or Move or Save the files
    NSMutableArray *reta;
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController dismissModalViewControllerAnimated:YES];
    NSError *error;
    
    switch (browsermode) {
        case kFolderBrowserSaveNewBlankFormMode: 
            NSLog(@"Need to save individual form in new directory");
            NSString *destPath = [NSString stringWithFormat:@"%@/%@", folder.path, folder.screenName];
            NSString *sourcePath = [NSString stringWithFormat:@"%@/%@.pdf", [tmpPDF path], [tmpPDF screenName]];
            [PDFFileDescriptor newPDFFileDescriptorWithSourcePath:sourcePath 
                                               andDestinationPath:destPath 
                                                          andName:tmpPDF.screenName
                                                              err:&error];
 
            [sharedFileManager removeItemAtPath:tmpPDF err:&error];
            [tmpPDF release];
            [self doneButtonSelected];
            break;
            
        case kFolderBrowserSaveNewBlankPortfolioMode: 
 			NSLog(@"need to find a place to save the save portfolio and populate the other files");
            //
            //	Create a new portfolio in the selected destination directory.
            //
            PortfolioDescriptor *parent = [sharedFileManager GetParent:currentPDF];
            
			NSString *newPortfolioPath = [NSString stringWithFormat:@"%@/%@", folder.path, folder.screenName];
			PortfolioDescriptor *newPortfolio =  [[PortfolioDescriptor newPortfolioDescriptorWithPath:newPortfolioPath
																							  andName:[parent screenName]
                                                                                                  err:&error] retain];
			if(newPortfolio) {
                // link new portfolio to folder in core data. 
				NSString *sourcePath = [NSString stringWithFormat:@"%@/%@.pdf", [tmpPDF path], [tmpPDF screenName]];
				NSString *destPath =[NSString stringWithFormat:@"%@/%@%",newPortfolioPath,[(PortfolioDescriptor *)parent screenName]];
				PDFFileDescriptor *pdf = (PDFFileDescriptor *)[PDFFileDescriptor newPDFFileDescriptorWithSourcePath:sourcePath 
                                                                                                 andDestinationPath:destPath 
                                                                                                            andName:tmpPDF.screenName
                                                                                                                err:&error];
				if(pdf) {
					[self replicateFieldsfromPDF:pdf fromPortfolio:(PortfolioDescriptor *)parent toPortfolio:newPortfolio];
				}
			}
            else {
                   UIAlertView *alert = [[UIAlertView alloc]
                                         initWithTitle: @"Portfolio Write Error"
                                         message: [error localizedDescription]
                                         delegate: nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
                   [alert show];
                   [alert release]; 
                [onScreen resetList];
            }

            [sharedFileManager removeItemAtPath:tmpPDF err:&error];
            [tmpPDF release];
            [self doneButtonSelected];
           break;
            
        case kFolderBrowserCopyMode: 
            reta = [onScreen getSelected];
            
            for(id next in reta) {
                if([sharedFileManager copyFolderOrPortfolioOrFile: next to:(FolderDescriptor *)folder err:&error] == NO) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Copy Error"
                                          message: [error localizedDescription]
                                          delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];                }
            }
            [onScreen resetList];
            [self doneButtonSelected];
            break;
            
        case kFolderBrowserMoveMode: 
            reta = [onScreen getSelected];
            
            for(id next in reta) {
                if([sharedFileManager moveFolderOrPortfolioOrFile: next to:(FolderDescriptor *)folder err:&error] == NO) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Move Error"
                                      message: [error localizedDescription]
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
            [onScreen resetList];
            [self doneButtonSelected];
            break;
            
    }
}

-(void)FolderBrowserCancelEntered
{
 	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController dismissModalViewControllerAnimated:YES];
   
}
-(void) copySelected
{
    FolderBrowser *f = [[FolderBrowser alloc] initWithNibName:@"FolderBrowser" bundle:nil mode:kFolderBrowserCopyMode target:self root:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] blocked:curFolder];
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController presentModalViewController:f animated:YES];
    [f release];
}

-(void) moveSelected
{
    FolderBrowser *f = [[FolderBrowser alloc] initWithNibName:@"FolderBrowser" bundle:nil mode:kFolderBrowserMoveMode target:self root:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] blocked:curFolder];
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController presentModalViewController:f animated:YES];
    [f release];
}

-(void) renameButtonSelected: (id) sender event: (UIEvent *)event
{
    FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGPoint p =[[event.allTouches anyObject] locationInView:fapp.window];
    folderOrPortfolioFlag = 2;  // used in the portfolioname callback to specify folder or portfolio
	[portfolioName showPortfolioName:CGRectMake(p.x, p.y, 20, 20)];

}
-(void) addFolderSelected: (id)sender event:(UIEvent*)event
{
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGPoint p =[[event.allTouches anyObject] locationInView:fapp.window];
    folderOrPortfolioFlag = 0;  // used in the portfolioname callback to specify folder or portfolio
	[portfolioName showPortfolioName:CGRectMake(p.x, p.y, 20, 20)];
}
-(void) makePortfolioSelected: (id)sender event:(UIEvent*)event
{
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGPoint p =[[event.allTouches anyObject] locationInView:fapp.window];
    folderOrPortfolioFlag = 1;  // used in the portfolioname callback to specify folder or portfolio
	[portfolioName showPortfolioName:CGRectMake(p.x, p.y, 20, 20)];
}

-(void) editOn
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected)];
	navItem.rightBarButtonItem = editButton;
    [editButton release];
    if([[sharedFileManager GetItemPath:curFolder] isEqualToString:[sharedFileManager GetItemPath:rootFolder]])
        navItem.leftBarButtonItem = nil;
    else {
        [bb setTitle:[(FolderDescriptor *)[sharedFileManager GetParent:curFolder] screenName] forState:UIControlStateNormal];
        navItem.leftBarButtonItem =  backButton;
    }
//    navItem.leftBarButtonItem = nil;
    
}
-(void)editOff
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
	navItem.rightBarButtonItem = editButton;
    [editButton release];
    if(folderMode == kFolderMode) {
        UIBarButtonItem *addFolder = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addfolder.png"] style:    UIBarButtonItemStylePlain target:self action:@selector(addFolderSelected:event:)];
       
        navItem.leftBarButtonItem = addFolder;
        [addFolder release];
    }

}
-(void) editButtonSelected
{
    [self scrollBarOn:YES];
    [self editOff];
    [onScreen beginEdit];
}
-(void) doneButtonSelected
{
    [self scrollBarOff:YES];
    [onScreen endEdit];
    [self editOn];
    [self initButtonBar];
}

-(void)setRoot:(id)folder andMode:(int)mode
{
    [self initButtonBar];
    folderMode = mode;
    rootFolder = curFolder = folder;
    [self resetTablePosition];
    [self editOn];
    [onScreen endEdit];
    [fileTable0 setPath:folder  target:self];
    [navItem setTitle:[(FolderDescriptor *)folder screenName]];
}

//
//  ButtonBar.  varies depending on the mode:
//
//  Form Mode:
//      Delete, email, move, rename (when just one selected), make Portfolio (when more than one selected)
//  Folder MOde:
//      Delete, email, move, copy, rename (when just one selected)
//  Portfolio Mode
//      delete, email, move, rename
-(void) initButtonBar
{
    [deleteButton setEnabled:NO];
    [emailButton setEnabled:NO];
    [renameButton setEnabled:NO];
    [copyButton setEnabled:NO];
    [moveButton setEnabled:NO];
   [makePortfolioButton setEnabled:NO];
 }
#pragma mark callback  methods (FileTableView delegate)
//
//  # of selected items in edit moved changed.
//
-(void) updateSelectionCount: (int) i
{
    switch(folderMode) {
        case kFormMode:
            [deleteButton setEnabled:(i > 0) ? YES: NO];
            [emailButton setEnabled:(i > 0) ? YES: NO];
            [renameButton setEnabled:(i ==1) ? YES: NO];
            [makePortfolioButton setEnabled:(i > 1) ? YES: NO];
            break;
        case kFolderMode:
            [deleteButton setEnabled:(i > 0) ? YES: NO];
            [emailButton setEnabled:(i > 0) ? YES: NO];
            [moveButton setEnabled:(i > 0) ? YES: NO];
            [renameButton setEnabled:(i ==1) ? YES: NO];
            [copyButton setEnabled:(i > 0) ? YES: NO];
            [makePortfolioButton setEnabled:NO];
            break;
        case kPortfolioMode:
            [deleteButton setEnabled:(i > 0) ? YES: NO];
            [emailButton setEnabled:(i > 0) ? YES: NO];
            [renameButton setEnabled:(i ==1) ? YES: NO];

            break;
    }
}

//
//  folder selected
//
-(void)changeDirectory:(id)newDirectory
{
    [offScreen setPath:newDirectory  target:self];        // load up off screen table
    CGRect r = offScreen.frame;
    r.origin.x = r.size.width;
    offScreen.frame = r;

    [UIView beginAnimations:@"ScrollTable" context:NULL];
    [UIView setAnimationDuration:.3];
    r.origin.x = 0;
    offScreen.frame = r;
    r.origin.x = -r.size.width;
    onScreen.frame = r;
    FileTableView *save = onScreen;
    onScreen = offScreen;
    offScreen = save;
    [UIView commitAnimations];
    [bb setTitle:[(FolderDescriptor *)curFolder screenName] forState:UIControlStateNormal];
    navItem.leftBarButtonItem = backButton;
    curFolder = (FolderDescriptor *)newDirectory;
    [navItem setTitle:[(FolderDescriptor *)curFolder screenName]];
    
}
//
//  A PDF file was selected from the table.  We'll now launchthe PDF reader and editor
//

-(void) fileSelected:(id)pdfFile
{
	NSError *error;
    
    currentPDF = (PDFFileDescriptor *)pdfFile;
	
	tmpPDF = [[sharedFileManager MakeTempPDF:currentPDF] retain];
	
	pdfViewController = [[PDFViewController alloc] initWithNibName:@"PDFViewController" bundle:nil];
    pdfViewController.delegate = self;
    
	NSString *filePath = [NSString stringWithFormat:@"%@/%@.pdf", tmpPDF.path, tmpPDF.screenName];
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:filePath] autorelease];
	
    
    //    [DSBezelActivityView newActivityViewForView:dv];
    //     [DSBezelActivityView newActivityViewForView:self.nvc.navigationBar.superview];
    //   [DSBezelActivityView newActivityViewForView:[tabBarController view]];
    BOOL isLoaded = [pdfViewController PdfLoadFile:fileURL error:&error];
    //    [DSBezelActivityView removeViewAnimated:YES];
 	if (isLoaded == FALSE) {
        
		UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"File Error" 
															message: [error localizedDescription]
														   delegate: self cancelButtonTitle: @"Ok" 
												  otherButtonTitles: nil];
		
		[someError show];
		[someError release];
        
		[sharedFileManager removeItemAtPath:tmpPDF err:&error];
		[tmpPDF release];
		[pdfViewController release];
		return;
	}
    
	pdfViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController presentModalViewController:pdfViewController animated:YES];
	return;    
}
//
//  A file was edited and saved.   Save logic varies depending on what was edited:
//
//  If this was a stand alone blank form, then request a save directory and save this one file.
//  If this was a file from one of the blank portfolio files, then request a save directory, create a new portfolio, save the
//      file in that new portfolio and then go through all of the other files in the blank portfolio and fill in each of
//      the forms with similar fields, save those files in the new porfolio and then finally save the edited file.
//  If this is a file from a portfolio that wasn't blank that ask if the other fields should be updated.  If not, save the file in the
//      portfolio.  If yes, then also update all of the portfolio files
//

-(void) PDFdidFinishWithResult:(PDFViewResult)result object:(NSString *)DFDoutput
{
	FormationV2AppDelegate *fapp = (FormationV2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [fapp.viewController dismissModalViewControllerAnimated:YES];
 
    [pdfViewController release];
    pdfViewController = nil;
    saveMode= -1;
    self.DFDresult = DFDoutput;
    NSError *error;
    
    if (result == PDFViewResultSave) {
        // determine whatkind of save this is.
        
        id parent = [sharedFileManager GetParent: (PDFFileDescriptor *)currentPDF];
//
//  If original was from blank forms, need to find a place to save the editied file.
//
        if([((FolderDescriptor *)parent).path isEqualToString:[sharedFileManager allForms].path] &&
           [((FolderDescriptor *)parent).screenName isEqualToString:[sharedFileManager allForms].screenName]) {
            saveMode = kFolderBrowserSaveNewBlankFormMode;
        }
        else if([parent isKindOfClass:[PortfolioDescriptor class]]) {       // part of portfolio.  In AllPortfolios?
            id pparent = [sharedFileManager GetParent:parent];
            if([((PortfolioDescriptor *)pparent).path isEqualToString:[sharedFileManager allPortfolios].path] &&
               [((PortfolioDescriptor *)pparent).screenName isEqualToString:[sharedFileManager allPortfolios].screenName]) {
                saveMode = kFolderBrowserSaveNewBlankPortfolioMode;
            }
            else {
                saveMode = kFolderBrowserSaveFormFromExistingPortfolioMode;
            }
        } else {
            saveMode = kFolderBrowserSaveExistingFormMode;
        }
        
        switch (saveMode) {
            UIAlertView *someError;
            
            case kFolderBrowserSaveExistingFormMode:        // save existing file
                NSLog(@"just save the file");
                [sharedFileManager removeItemAtPath:currentPDF err:&error];			// blow away the old file.
                [sharedFileManager copyPDFFileToFolderOrPortfolio:parent withFile:tmpPDF err:&error];	// make a new copy
                [currentPDF setLastModifiedDate:[NSDate date]];				// update modification date.
                [sharedFileManager removeItemAtPath:tmpPDF err:&error];
               [tmpPDF release];
                [self doneButtonSelected];
                break;
                
            case kFolderBrowserSaveFormFromExistingPortfolioMode:  // save file from existing portfolio
                [sharedFileManager removeItemAtPath:currentPDF err:&error];			// blow away the old file.
                [sharedFileManager copyPDFFileToFolderOrPortfolio:parent withFile:tmpPDF err:&error];	// make a new copy
                [currentPDF setLastModifiedDate:[NSDate date]];				// update modification date.
                
                UIAlertView* dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:self];
                [dialog setTitle:@"Portfolio Alert"];               // DONT CHANGE THIS NAME; USED IN DIALOG CALLBACK
                [dialog setMessage:@"This PDF file is part of a portfolio.  Do you wish to replicate identical fields from this file to the others in the portfolio?"];
                [dialog addButtonWithTitle:@"Yes"];
                [dialog addButtonWithTitle:@"No"];
                [dialog show];
                [dialog release];                           // The actual duplication will take place in the dialog callback.
                break;
                
            case kFolderBrowserSaveNewBlankFormMode:        // save blank form in             
 
                 someError = [[UIAlertView alloc] initWithTitle: @"File Save" 
                                                                    message: @"You need to select the folder to save a copy of this file, then press \"Save\""
                                                                   delegate: self cancelButtonTitle: @"Ok" 
                                                          otherButtonTitles: nil];
                
                [someError show];
                [someError release];

                break;
                
            case kFolderBrowserSaveNewBlankPortfolioMode:   // save blank form in 
                someError = [[UIAlertView alloc] initWithTitle: @"Portfolio Save" 
                                                                    message: @"You need to select the folder to save a copy of the portfolio containing this file as well as the others, then press \"Save\""
                                                                   delegate: self cancelButtonTitle: @"Ok" 
                                                          otherButtonTitles: nil];
                
                [someError show];
                [someError release];
                

                break;
        }
        
    } else {        // error or cancel, remove tempory file
    
        [sharedFileManager removeItemAtPath:tmpPDF err:&error];
        [tmpPDF release];
        [onScreen resetList];
    }

}

-(IBAction) backButtonSelected
{
    curFolder = [sharedFileManager GetParent:curFolder];
    [offScreen setPath:curFolder  target:self];        // load up off screen table

    CGRect r = offScreen.frame;
    r.origin.x = -r.size.width;
    offScreen.frame = r;
    
    [UIView beginAnimations:@"ScrollTable" context:NULL];
    [UIView setAnimationDuration:.3];
    r.origin.x = 0;
    offScreen.frame = r;
    r.origin.x = r.size.width;
    onScreen.frame = r;
    FileTableView *save = onScreen;
    onScreen = offScreen;
    offScreen = save;
    [UIView commitAnimations];
    [navItem setTitle:[(FolderDescriptor *)curFolder screenName]];
    if([[sharedFileManager GetItemPath:curFolder] isEqualToString:[sharedFileManager GetItemPath:rootFolder]])
        navItem.leftBarButtonItem = nil;
    else
        [bb setTitle:[(FolderDescriptor *)[sharedFileManager GetParent:curFolder] screenName] forState:UIControlStateNormal];
   
}

#pragma mark  PortfolioName methods
//
//  A name has been entered in a dialog box for either a new folder (addFolder) or for the name of a new Portfolio.
//  If new folder, create a new subfolder under this directory.
//
//  If a portfolio, create a new portfolio under ALLPORTFOLIOS with the new name and then pull all of the selected files
//  and add them to the new portfolio.
//

-(void)folderNameEntered:(NSString *)name
{
    NSError *error;
    if (folderOrPortfolioFlag == 0) {
        NSString *subfolderPath = [NSString stringWithFormat:@"%@/%@", [(FolderDescriptor *)curFolder path], [(FolderDescriptor *)curFolder     screenName]];
        [[FolderDescriptor newFolderDescriptorWithPath:subfolderPath 
                                               andName:name err:&error] retain];
   }
    
    else if (folderOrPortfolioFlag == 1) {      // confirmed create portfolio.
        
		PortfolioDescriptor *newPortfolio =  [PortfolioDescriptor newPortfolioDescriptorWithPath:ALLPORTFOLIOS_PATH 
                                                                                          andName:name err:&error];
		if(newPortfolio != nil) {
            NSMutableArray *reta = [onScreen getSelected];
            
            for(PDFFileDescriptor *next in reta) {
                NSString *sourcePath = [NSString stringWithFormat:@"%@/%@.pdf", [next path], [next screenName]];
                NSString *destPath = [NSString stringWithFormat:@"%@/%@", [newPortfolio path], [newPortfolio screenName], [next screenName]];
                [PDFFileDescriptor newPDFFileDescriptorWithSourcePath:sourcePath 
                                                   andDestinationPath:destPath 
                                                              andName:[next screenName] err:&error];
 
            }
            [newPortfolio release];
       }
        else {
 			UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Portfolio Error" 
                                                                message: [error localizedDescription]
                                                               delegate: self cancelButtonTitle: @"Ok" 
                                                      otherButtonTitles: nil];
            
			[someError show];
			[someError release];
           
        }
    }
    else if (folderOrPortfolioFlag == 2) {
        NSError *error;
        NSMutableArray *reta = [onScreen getSelected];
        id next = [reta objectAtIndex:0];
        if(next != nil) {
            [sharedFileManager renameFolderOrPortfolioOrFile:next  to:name err:&error];
        }
    }
    
    [self doneButtonSelected];
    [onScreen resetList];
}

-(void) dealloc
{
    [portfolioName release];
    [bb release];
    [backButton release];
    [super dealloc];
}
@end
