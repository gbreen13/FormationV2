//
//  PdfCHField.h
//  Formation
//
//  Created by George Breen on 1/30/11.
//  Copyright 2011 Rabbit Hill Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfField.h"

@interface PdfCHField : PdfField {

}

-(id) initWithObjno:(int)objNo andGeneration:(int)genNo andDictionary:(PdfDictionary *)fieldDictionary;
-(BOOL) isComboBit;
-(void) setComboBit;
-(BOOL) isEditBit;
-(void) setEditBit;
-(BOOL) isSortBit;
-(void) setSortBit;
-(BOOL) isMultiSelectBit;
-(void) setMultiSelectBit;
-(BOOL) isDoNotSpellCheckBit;
-(void) setDoNotSpellCheckBit;
-(void) setSelectedIndices:(NSMutableArray *)indices;
-(NSMutableArray *) getSelectedIndices;
-(void) addToView: (UIView *)view withPageRect: (CGRect) pageRect;
@end
