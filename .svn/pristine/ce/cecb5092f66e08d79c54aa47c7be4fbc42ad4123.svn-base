//
//  FolderDescriptor.h
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FileDescriptor.h"


@interface FolderDescriptor :  FileDescriptor  
{
}


+ (id)newFolderDescriptorWithPath:(NSString *)fname andName:(NSString *)name err:(NSError **)error;
+ (FolderDescriptor *) GetRootDescriptor;
+ (FolderDescriptor *) GetFolderDescriptorWithPath:(NSString *)path andName:fname;


-(NSArray *) GetSubfolders;
-(NSArray *) GetPortfolios;
-(NSArray *) GetFiles;
-(NSArray *) GetContents;
-(int) GetContentCount;

@end

