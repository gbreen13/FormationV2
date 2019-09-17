//
//  FolderBrowser.h
//  Formation
//
//  Created by George Breen on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "FileManager.h"
 
@protocol FolderBrowserDelegate
-(void)FolderBrowserOKEntered: (FolderDescriptor *)folder mode:(int)m;
-(void)FolderBrowserCancelEntered;
@end

#define kFolderBrowserCopyMode 0
#define kFolderBrowserMoveMode 1
#define kFolderBrowserSaveNewBlankFormMode 2
#define kFolderBrowserSaveNewBlankPortfolioMode 3
#define kFolderBrowserSaveExistingFormMode 4
#define kFolderBrowserSaveFormFromExistingPortfolioMode 5

#define kFolderBrowserTableCellHeight 26
@interface FolderCell :NSObject {
    int indentLevel;
    BOOL isExpanded;
    FolderDescriptor *folder;
}
@property (nonatomic, retain) FolderDescriptor *folder;
@property int indentLevel;
@property BOOL isExpanded;
@end

@interface FolderBrowser : UIViewController <UITableViewDelegate,  UITableViewDataSource> {
    IBOutlet UINavigationBar *navBar;
    IBOutlet UINavigationItem *navItem;
    IBOutlet UITableView *table;
    
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *rightButton;
	id<FolderBrowserDelegate> _caller;
    int mode;
    int curselected;
    int numberRows;
    FolderDescriptor *root, *blocked;
    
    NSMutableArray *folderList;
}

-(IBAction) cancelSelected;
-(IBAction) OKSelected;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(int)m target:(id)t root:(FolderDescriptor *)r blocked:(FolderDescriptor *)f2;
-(void) addFolder: (FolderDescriptor *)folder at:(int) location indent:(int)i;
-(void) selectFolder: (int) index;

@property (nonatomic, assign) id<FolderBrowserDelegate> caller;

@end
