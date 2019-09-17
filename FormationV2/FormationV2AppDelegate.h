//
//  FormationV2AppDelegate.h
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileManager.h"

// test for checkin

@class FormationV2ViewController;

@interface FormationV2AppDelegate : NSObject <UIApplicationDelegate> {
    FormationV2ViewController   *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet FormationV2ViewController *viewController;

@end
