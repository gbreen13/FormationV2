//
//  PortfolioDescriptor.h
//  Formation
//
//  Created by George Breen on 2/20/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import "FileDescriptor.h"

@interface PortfolioDescriptor :  FileDescriptor
{
}

+ (PortfolioDescriptor *) newPortfolioDescriptorWithPath:(NSString *)fname andName:(NSString *)name err:(NSError **)error;
+ (PortfolioDescriptor *) GetPortfolioDescriptorWithPath:(NSString *)dpath andName:fname;
-(NSArray *) GetPortfolioFiles;
-(BOOL) DeletePortfolioAndFiles:(NSError **)error;
-(int) GetContentCount;

@end

