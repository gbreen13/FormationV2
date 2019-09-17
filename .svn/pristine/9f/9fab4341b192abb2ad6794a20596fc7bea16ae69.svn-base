//
//  FileScrollerView.h
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FormationV2AppDelegate.h"
#import "FileManager.h"
#import "FileTableView.h"
#import "PortfolioName.h"
#import "PDFViewController.h"
#import "FolderBrowser.h"

#define kFormMode 1
#define kFolderMode 2
#define kPortfolioMode 3

#define kBarHeight 44

@interface FileScrollerView : UIView  <PortfolioNameDelegate, MFMailComposeViewControllerDelegate, PDFViewDelegate, FolderBrowserDelegate> {
    int folderMode;
    
    IBOutlet FileTableView *fileTable0, *fileTable1;
    FileTableView *onScreen, *offscreen;
    BOOL buttonBarOn;
    BOOL isEditing;
    
    FolderDescriptor *rootFolder;            // top folder
    FolderDescriptor *curFolder;             // folder currently shown on table
    
    IBOutlet UIView *buttonBar;
    IBOutlet UIView *tableViewport;
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *copyButton;
    IBOutlet UIButton *moveButton; 
    IBOutlet UIButton *addFolderButton;
    IBOutlet UIButton *makePortfolioButton;
    IBOutlet UIButton *renameButton;
    
    IBOutlet UINavigationBar *navBar;
    IBOutlet UINavigationItem *navItem;
    
    UIBarButtonItem *backButton;
    UIButton *bb;
    
    int    folderOrPortfolioFlag;          // 0 = make folder from name, 1 = make portfolio
	PortfolioNameController *portfolioName;
	PDFFileDescriptor *currentPDF, *tmpPDF;
	PDFViewController *pdfViewController;
    
    NSString *DFDresult;
    int saveMode;

}

@property (nonatomic, retain) UIButton *deleteButton, *emailButton, *copyButton, *moveButton, *addFolderButton;
@property (nonatomic, retain) FileTableView *fileTable0, *fileTable1;
@property (nonatomic, assign) FileTableView  *onScreen, *offScreen;           // points at either table0 or table1
@property (nonatomic, assign) PortfolioNameController *portfolioName;
@property (nonatomic, assign) FolderDescriptor *rootFolder, *curFolder;
@property (nonatomic, assign) UIBarButtonItem *backButton;
@property (nonatomic, assign) UIButton *bb;
@property (nonatomic, assign) PDFFileDescriptor *currentPDF, *tmpPDF;
@property (nonatomic, retain) IBOutlet PDFViewController *pdfViewController;
@property (nonatomic, copy) NSString *DFDresult;
@property int saveMode;
           
@property int folderOrPortfolioFlag;

-(IBAction) deleteSelected;
-(IBAction) emailSelected;
-(IBAction) copySelected;
-(IBAction) moveSelected;
-(IBAction) addFolderSelected: (id)sender event:(UIEvent*)event;
-(IBAction) makePortfolioSelected: (id)sender event:(UIEvent*)event;
-(IBAction) editButtonSelected;
-(IBAction) backButtonSelected;
-(IBAction) renameButtonSelected: (id) sender event: (UIEvent *)event;

-(void) scrollBarOff: (BOOL) animated;
-(void) scrollBarOn: (BOOL) animated;
-(void) resetTablePosition;
-(void) initTable;
-(void) setRoot: (id)rootFolder andMode:(int) mode;
-(void) editOn;
-(void) editOff;
-(void) initButtonBar;
-(void) doneButtonSelected;
-(void) PDFdidFinishWithResult: (PDFViewResult)result object:(NSString *)DFDData;
-(void) replicateFieldsfromPDF:(PDFFileDescriptor *)pdf fromPortfolio:(PortfolioDescriptor *)oldPortfolio toPortfolio:(PortfolioDescriptor *)newPortfolio;
@end
