//
//  FolderBrowser.m
//  Formation
//
//  Created by George Breen on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderBrowser.h"

@implementation FolderCell
@synthesize indentLevel,folder, isExpanded;
@end


@implementation FolderBrowser
@synthesize caller = _caller;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(int)m target:(id)t root:(FolderDescriptor *)r
        blocked:(FolderDescriptor *)f2
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil) {
        mode = m;
        root = r;
        _caller = t;
        numberRows = 0;
        curselected = -1;
        blocked = f2;
        folderList = [[NSMutableArray alloc]initWithCapacity:20];
        self.modalPresentationStyle = UIModalPresentationFormSheet;   
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch(mode) {
        case kFolderBrowserCopyMode:
            [navItem setTitle:@"Select Destination Folder for Copy"];
            [rightButton setTitle:@"Copy"];
            [cancelButton setEnabled:YES];
           break;
        case kFolderBrowserMoveMode:
            [navItem setTitle:@"Select Destination Folder for Move"];
            [rightButton setTitle:@"Move"];
            [cancelButton setEnabled:YES];
            break;
        case kFolderBrowserSaveNewBlankFormMode:
            [navItem setTitle:@"Select Folder to Save Edited File"];
            [rightButton setTitle:@"Save"];
            [cancelButton setEnabled:NO];
            break;
        case kFolderBrowserSaveNewBlankPortfolioMode:
            [navItem setTitle:@"Select Folder to Create New Portfolio"];
            [rightButton setTitle:@"Save"];
            [cancelButton setEnabled:NO];
            break;
  }
    [self addFolder:root at:0 indent:0];
//    [self selectFolder: 0];
    [table reloadData];
}

-(void) addFolder:(FolderDescriptor *)f at:(int) index indent:(int)ind
{
    FolderCell *c = [[FolderCell alloc]init ];
    c.indentLevel = ind;
    c.folder = f;
    if(index == [folderList count])
        [folderList addObject:c];
    else
        [folderList insertObject:c atIndex:index+1];
    numberRows++;
    [table insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index+1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

-(void) selectFolder: (int)index
{
    FolderCell *c = [folderList objectAtIndex:index];
    
    NSArray *subFolders = [c.folder GetSubfolders];
    if((subFolders != nil) && ([subFolders count] > 0) && !c.isExpanded) {
    
        for(int i = 0; i <[subFolders count]; i++) {
            [self addFolder:[subFolders objectAtIndex:i] at:index+i indent:c.indentLevel+1];
        }
        c.isExpanded = TRUE;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kFolderBrowserTableCellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberRows;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FolderCell *fc = [folderList objectAtIndex:[indexPath row]];
    return fc.indentLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    FolderCell *c = [folderList objectAtIndex:[indexPath row]];
    
    cell.imageView.image= [UIImage imageNamed:@"folder.png"];
    [[cell textLabel] setText:[NSString stringWithFormat:@"/%@", [c.folder screenName]]]; 
    cell.textLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
    cell.indentationLevel = c.indentLevel;
    
    if(c.folder == blocked) {
        [cell.textLabel setTextColor:[UIColor grayColor]];
    } else {
         [cell.textLabel setTextColor:[UIColor blackColor]];
    }
          
    if([indexPath row] == curselected)
        [cell setSelected:YES animated:NO];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FolderCell *c = [folderList objectAtIndex:[indexPath row]];
    if(c.folder != blocked) {       // dont select the blocked one.
        [tableView beginUpdates];
        [self selectFolder:curselected = [indexPath row]];
        [tableView endUpdates];
    }
//    [table reloadData];
}
             
#pragma  mark - Callback routines

             
-(IBAction) cancelSelected
{
    if(_caller != nil) {
        [_caller FolderBrowserCancelEntered];
    }
}

-(IBAction) OKSelected
{
    if(_caller != nil) {
        if(curselected == -1){
            [_caller FolderBrowserOKEntered:root mode:mode];
        } else {  
            FolderCell *f = [folderList objectAtIndex:curselected];
            [_caller FolderBrowserOKEntered:f.folder mode:mode];
        }
    }
}

-(void) dealloc
{
    while([folderList count]) {
        FolderCell *c = [folderList objectAtIndex:0];
        [c release];
        [folderList removeObjectAtIndex:0];
    }
    [folderList release];
    [super dealloc];
}
@end
