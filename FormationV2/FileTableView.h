//
//  FileTableView.h
//  FormationV2
//
//  Created by George Breen on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileManager.h"
#import "MultiSelectTableViewCell.h"

#define kFileTableCellIdentifier @"FileTableCell"
#define kTableCellHeight    100
#define SELECTION_INDICATOR_TAG 54321
#define NTEXT_LABEL_TAG 54322
#define EDITING_HORIZONTAL_OFFSET  35
#define kImageIconWidth 88
#define kImageIconHeight 88
@protocol FileTableDelegate
-(void)changeDirectory: (id)fileOrFolder;
-(void)updateSelectionCount: (int)i;
-(void)fileSelected:(id)file;
@end

@interface CellList : NSObject
{
    id fileOrFolder;
    BOOL selected;
}
@property (nonatomic, retain) id fileOrFolder;
@property BOOL selected;
@end

@interface FileTableView : UITableView <UITableViewDelegate,  UITableViewDataSource>{
    
    NSMutableArray *fileList;
    id root;						// current container for this list.
    id<FileTableDelegate>  caller;
}

@property (nonatomic, assign) NSMutableArray *fileList;
@property (nonatomic, assign) id caller;
@property (nonatomic, retain) id root;
-(void) setPath: (id)rootFolder  target:id;
-(void) beginEdit;
-(void) endEdit;
-(NSMutableArray *)getSelected;
-(void) resetList;
@end
