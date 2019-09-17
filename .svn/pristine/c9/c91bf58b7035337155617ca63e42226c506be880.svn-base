//
//  FormationV2ViewController.m
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormationV2ViewController.h"

@implementation FormationV2ViewController

@synthesize formSelectButton, portfolioSelectButton, folderSelectButton, fileView;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"metalpattern.png"]];
    [fileView initTable];
    [self formSelected:nil];
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(IBAction) formSelected: (id)sender
{
	[fileView	setRoot:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFORMS_FOLDER] andMode:kFormMode];
}

-(IBAction) portfolioSelected: (id)sender
{
	[fileView	setRoot:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLPORTFOLIOS_FOLDER] andMode:kPortfolioMode];
}

-(IBAction) folderSelected: (id)sender
{
	[fileView	setRoot:[FolderDescriptor GetFolderDescriptorWithPath:ROOT_PATH andName:ALLFOLDERS_FOLDER] andMode:kFolderMode];
}


@end
