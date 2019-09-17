//
//  FormationV2AppDelegate.m
//  FormationV2
//
//  Created by George Breen on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormationV2AppDelegate.h"

#import "FormationV2ViewController.h"

@implementation FormationV2AppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	sharedFileManager = [[FileManager alloc] init];
	[sharedFileManager initFileFolders];
	
	NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
	
	if ([url isFileURL])
	{
		[sharedFileManager addFileToAllForms:url];
		// Handle file being passed in
	}    
     self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL - %@", [url absoluteURL]);
 
    
    [sharedFileManager addFileToAllForms:[url absoluteURL]];
    
    [self.viewController formSelected:nil];
    
    NSString* fileNameWithExtension = url.lastPathComponent;
    NSString* fileName = [fileNameWithExtension stringByDeletingPathExtension];   
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"File Added" 
                                                        message: [NSString stringWithFormat:@"%@ added to Blank Forms", fileName]
                                                       delegate: nil cancelButtonTitle: @"Ok" 
                                              otherButtonTitles: nil];      
    [someError show];
    [someError release];    
    return YES;  
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
