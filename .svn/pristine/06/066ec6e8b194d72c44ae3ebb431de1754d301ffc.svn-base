//
//  FileTableView.m
//  FormationV2
//
//  Created by George Breen on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileTableView.h"

@implementation CellList 
@synthesize fileOrFolder, selected;

@end

@implementation FileTableView
@synthesize fileList, caller, root;
#define IMAGEPADDING 10

-(UIImage *) centerScale: (UIImage *)im toWidth:(float)w andHeight: (float)h
{
	CGSize newsize;
	CGPoint newoff = CGPointZero; // im.origin;
	if(im.size.width < im.size.height) {	// portrait
		newsize.height = h;
		newsize.width = (newsize.height * im.size.width)/im.size.height;
		newoff.x += (im.size.width/2 - newsize.width/2); ;
	} else {
        // landscape
		newsize.width = w;
		newsize.height = (newsize.width * im.size.height)/im.size.width;
		newoff.y += (im.size.height/2 - newsize.height/2);
	}
	
    newsize.width += IMAGEPADDING;
	UIGraphicsBeginImageContext( newsize );
	[im drawInRect:CGRectMake(IMAGEPADDING,0,newsize.width,newsize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	if(fileList != nil)
        return [fileList count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kTableCellHeight;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{	
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
 	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kFileTableCellIdentifier];
	UIImageView *indicator;
    
	if (cell == nil) {
		cell = [[[MultiSelectTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kFileTableCellIdentifier]autorelease]; 
		indicator = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotSelected.png"]] autorelease];
		
		const NSInteger IMAGE_SIZE = 30;
		const NSInteger SIDE_PADDING = 5;
		
		indicator.tag = SELECTION_INDICATOR_TAG;
		indicator.frame =
        CGRectMake(-EDITING_HORIZONTAL_OFFSET + SIDE_PADDING, (0.5 * kTableCellHeight) - (0.5 * IMAGE_SIZE), IMAGE_SIZE, IMAGE_SIZE);
		[cell.contentView addSubview:indicator];
       
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
 		cell.backgroundView =
        [[[UIImageView alloc] init] autorelease];
		cell.selectedBackgroundView =
        [[[UIImageView alloc] init] autorelease];  
   }
 	else
	{
		indicator = (UIImageView *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG];
	}

    int row = [indexPath row];
    
    CellList *c = [fileList objectAtIndex:row];
    id thisItem = c.fileOrFolder;
    
	//
	// Set the background and selected background images for the text.
	// Since we will round the corners at the top and bottom of sections, we
	// need to conditionally choose the images based on the row index and the
	// number of rows in the section.
	//
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = [self numberOfRowsInSection:[indexPath section]];
	if (row == 0 && row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
	}
	else if (row == 0)
	{
		rowBackground = [UIImage imageNamed:@"topRow.png"];
		selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
	}
	else if (row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"bottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
	}
	else
	{
		rowBackground = [UIImage imageNamed:@"middleRow.png"];
		selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
	}
	((UIImageView *)cell.backgroundView).image = rowBackground;
	((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;

    if (c.selected)
    {
 //       cell.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:0.3];
        indicator.image = [UIImage imageNamed:@"IsSelected.png"];
    }
    else
    {
        indicator.image = [UIImage imageNamed:@"NotSelected.png"];
 //       cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    }
    
    if ([thisItem isKindOfClass:[PDFFileDescriptor class]]) {	// note iskindof class doesn't 	return cell;			
        PDFFileDescriptor *pdf = (PDFFileDescriptor *)thisItem;
        [[cell textLabel] setText:[pdf screenName]];
        cell.imageView.image= [self centerScale:[UIImage imageWithData:[pdf pDFThumb]] toWidth:kImageIconWidth andHeight:kImageIconHeight];
        cell.accessoryView=nil;
        [cell.detailTextLabel setText:nil];       //       cell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([thisItem isKindOfClass:[PortfolioDescriptor class]]){
        PortfolioDescriptor *pd = (PortfolioDescriptor *)thisItem;
        cell.imageView.image= [UIImage imageNamed:@"portfolio.png"];
        [[cell textLabel] setText:[[pd screenName]stringByDeletingPathExtension]];
        cell.accessoryView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"indicator.png"]]autorelease];
       int c = [pd GetContentCount];
        NSString *subt;
        switch (c)  {
            case 0:subt = @"Empty"; break;
            case 1:subt = @"1 Item"; break;
            default: subt = [NSString stringWithFormat:@"%d items", c]; break;
        }
        [cell.detailTextLabel setText:subt];
    } 
    else {
        FolderDescriptor *fd = (FolderDescriptor *)thisItem;
        [[cell textLabel] setText:[fd screenName]];
        cell.imageView.image= [UIImage imageNamed:@"folder.png"];
        cell.accessoryView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"indicator.png"]]autorelease];
        int c = [fd GetContentCount];
        NSString *subt;
        switch (c)  {
            case 0:subt = @"Empty"; break;
            case 1:subt = @"1 Item"; break;
            default: subt = [NSString stringWithFormat:@"%d items", c]; break;
        }
        [cell.detailTextLabel setText:subt];
   }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{	
	return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath 
{
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

	int row = [indexPath row];
    CellList *c = [fileList objectAtIndex:row];
    id thisItem = c.fileOrFolder;
    
    if(self.isEditing) {
        c.selected = !c.selected;
        if(caller != nil) {
            int i=0;
            for(CellList *cjunk in fileList) {
                if(cjunk.selected) i++;
            }
            [caller updateSelectionCount:i];
        }
        
        [self reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                         withRowAnimation: UITableViewRowAnimationNone];
    } else {
    
        if ([thisItem isKindOfClass:[FolderDescriptor class]]) {	// note iskindof class doesn't 	return cell;	
            if(caller != nil){
                [caller changeDirectory:thisItem];
            }    
        } else if ([thisItem isKindOfClass:[PortfolioDescriptor class]]){
            if(caller != nil){
                [caller changeDirectory:thisItem];
            }    
        } 
        else {
            [caller fileSelected:thisItem];
        }
    }
}
-(void) setPath: (id)folderOrPortfolio  target:id
{
//    [self beginUpdates];
    caller = id;
  
    if(fileList != nil) {
       [fileList removeAllObjects];
        [fileList release];
        fileList = nil;
    }


    self.root = folderOrPortfolio;

    if ([folderOrPortfolio isKindOfClass:[FolderDescriptor class]]) {
        
        FolderDescriptor *f = self.root;
        NSArray *a1 = [f GetSubfolders];
        NSArray *a2 = [f GetPortfolios];
        NSArray *a3 = [f GetFiles];
    
        fileList = [[NSMutableArray alloc]initWithCapacity:[a1 count]+[a2 count] + [a3 count]];
        for(NSManagedObject *next in a1) {
            CellList *c = [[[CellList alloc]init]autorelease];
            c.fileOrFolder = next;
            c.selected = NO;
            [fileList addObject:c];
        }
        for(NSManagedObject *next in a2) {
            CellList *c = [[[CellList alloc]init] autorelease];
            c.fileOrFolder = next;
            c.selected = NO;
            [fileList addObject:c];
        }
    
        for(NSManagedObject *next in a3) {
            CellList *c = [[[CellList alloc]init] autorelease];
            c.fileOrFolder = next;
            c.selected = NO;
            [fileList addObject:c];
        }
    } else {
        PortfolioDescriptor *p = (PortfolioDescriptor *)folderOrPortfolio;       
        NSArray *a = [p GetPortfolioFiles];
        fileList = [[NSMutableArray alloc]initWithCapacity:[a count]];
       for(NSManagedObject *next in a) {
           CellList *c = [[[CellList alloc]init] autorelease];
           c.fileOrFolder = next;
           c.selected = NO;
           [fileList addObject:c];
        } 
    }
 //   [self endUpdates];
    [self reloadData];
   
}

-(void) beginEdit
{
    [self setEditing:YES animated:YES];
}
-(void) endEdit
{
    for(CellList *c in fileList)
        c.selected = NO;
    
    [self setEditing:NO animated:YES];
    [self reloadData];
}
-(void) dealloc
{
    [fileList removeAllObjects];
    [fileList release];
    [super dealloc];
}

-(NSMutableArray *)getSelected
{
    NSMutableArray *reta = [[NSMutableArray alloc]initWithCapacity:1];
    for(CellList *c in fileList)
        if(c.selected)
            [reta addObject:c.fileOrFolder];
    return reta;
    
}
-(void) resetList
{
    [self setPath:self.root target:caller];
}


@end
