//
//  FormationV2ViewController.h
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileScrollerView.h"

#define kCellIdentifier @"FileCell"

@interface FormationV2ViewController : UIViewController {
    IBOutlet FileScrollerView *fileView;
    IBOutlet UIButton *formSelectButton;
    IBOutlet UIButton *portfolioSelectButton;
    IBOutlet UIButton *folderSelectButton;
}

@property (nonatomic, retain) IBOutlet UIButton *formSelectButton, *portfolioSelectButton, *folderSelectButton;
@property (nonatomic, retain) IBOutlet FileScrollerView *fileView;

-(IBAction) formSelected: (id)sender;
-(IBAction) portfolioSelected: (id)sender;
-(IBAction) folderSelected: (id)sender;

@end
