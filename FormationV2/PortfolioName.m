//
//  PortfolioName.m
//
//  Created by George Breen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PortfolioName.h"

@implementation PortfolioNameController
@synthesize cancelButton, saveButton, name, mode, navBar, portfolioNamePop;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.contentSizeForViewInPopover = CGSizeMake(kPortfolioNameWidth, kPortfolioNameHeight); 	
		portfolioNamePop = [[UIPopoverController alloc] initWithContentViewController:self];  
	}
	return self;
}
-(void) showPortfolioName: (CGRect) r
{
	self.contentSizeForViewInPopover = CGSizeMake(kPortfolioNameWidth, kPortfolioNameHeight); 	
	[portfolioNamePop presentPopoverFromRect:r inView: /*self.view*/(UIWindow*)[[UIApplication sharedApplication].windows 
																		  objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction) cancelButtonPressed: (id)sender
{
	[portfolioNamePop dismissPopoverAnimated:YES];
}

-(IBAction) saveButtonPressed: (id)sender
{
	if(_delegate != nil) {
		[_delegate folderNameEntered:name.text];
    }
	[portfolioNamePop dismissPopoverAnimated:YES];
}


@end