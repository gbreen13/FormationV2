//
//  PortfolioName.h
//
//  Created by George Breen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define kPortfolioNameWidth 353
#define kPortfolioNameHeight 85

#define kAddFolderMode	1
#define kAddPortfolioMode	2
#define kAddSubFolderMode 3
#define kRenameObjectMode 4

@protocol PortfolioNameDelegate
-(void)folderNameEntered: (NSString *)name;
@end

@interface PortfolioNameController: UIViewController <UIPopoverControllerDelegate>  {
	
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *saveButton;
	UIPopoverController *portfolioNamePop;
	UINavigationItem *navBar;
	UITextField *name;
	id<PortfolioNameDelegate> _delegate;
}
@property (nonatomic, assign) IBOutlet UIBarButtonItem *cancelButton, *saveButton;
@property (nonatomic, assign) IBOutlet UIPopoverController *portfolioNamePop;
@property (nonatomic, assign) IBOutlet UITextField *name;
@property (nonatomic, assign) IBOutlet UINavigationItem *navBar;
@property (nonatomic, assign) int mode;
@property (nonatomic, assign) id<PortfolioNameDelegate> delegate;

-(IBAction) cancelButtonPressed: (id)sender;
-(IBAction) saveButtonPressed: (id)sender;
-(void) showPortfolioName: (CGRect) r;


@end
