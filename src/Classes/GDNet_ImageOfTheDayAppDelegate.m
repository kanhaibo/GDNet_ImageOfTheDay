//
//  GDNet_ImageOfTheDayAppDelegate.m
//  GDNet_ImageOfTheDay
//
//  Created by Zbigniew Kominek on 1/26/11.
//  Copyright zbyhoo 2011. All rights reserved.
//

#import "GDNet_ImageOfTheDayAppDelegate.h"
#import "ImagesListViewController.h"
#import "SettingsViewController.h"
#import "DataManager.h"
#import "GDHtmlStringConverter.h"
#import "GDArchiveHtmlStringConverter.h"
#import "DBHelper.h"
#import "FavoritesListViewController.h"
#import "DevMasterListViewController.h"
#import "GameDevArchiveListViewController.h"
#import "AboutViewController.h"

@implementation GDNet_ImageOfTheDayAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch.
    
    // Setting up data manager
    [DBHelper setManagedContext:[self managedObjectContext]];
    
    // Initializing Images list view controller
    GameDevArchiveListViewController *imagesListViewController = [[GameDevArchiveListViewController alloc] 
                                                           initWithNibName:@"ImagesListViewController" bundle:nil];
    imagesListViewController.title = @"GameDev Archive";
    
    // Initializing navigation controller for main "Image of the Day" view
    imagesNavigationController = [[UINavigationController alloc] init];
    imagesNavigationController.navigationBar.tintColor = [UIColor blackColor];
    imagesNavigationController.tabBarItem.image = [UIImage imageNamed:@"gamedev_logo.png"];
    [imagesNavigationController pushViewController:imagesListViewController animated:NO];
    [imagesListViewController release];
    
    // Initializing DevMaster list view controller
    DevMasterListViewController *devMasterListViewController = [[DevMasterListViewController alloc] 
                                                          initWithNibName:@"ImagesListViewController" bundle:nil];
    devMasterListViewController.title = @"DevMaster";
    
    // Initializing navigation controller for main "DevMaster" view
    devMasterNavigationController = [[UINavigationController alloc] init];
    devMasterNavigationController.navigationBar.tintColor = [UIColor blackColor];
    devMasterNavigationController.tabBarItem.image = [UIImage imageNamed:@"devmaster_logo.png"];
    [devMasterNavigationController pushViewController:devMasterListViewController animated:NO];
    [devMasterListViewController release];
    
    // Initializing Favourites view controller
    FavoritesListViewController *favouritesViewController = [[FavoritesListViewController alloc] 
                                                             initWithNibName:@"ImagesListViewController" bundle:nil];
    favouritesViewController.title = @"Favorites";
    
    // Initializing navigation controller for "Favourites" view
    favouritesNavigationController = [[UINavigationController alloc] init];
    favouritesNavigationController.navigationBar.tintColor = [UIColor blackColor];
    favouritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"28-star.png"];
    [favouritesNavigationController pushViewController:favouritesViewController animated:NO];
    [favouritesViewController release];
    
    // Initializing about controller
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    aboutViewController.title = @"About";
    aboutViewController.tabBarItem.image = [UIImage imageNamed:@"09-chat-2.png"];
    
    // Initializing main bar controller
	tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:devMasterNavigationController,
                                                                 imagesNavigationController,
                                                                 favouritesNavigationController, 
                                                                 aboutViewController,
                                                                 nil];
    //[settingsViewController release];
    [aboutViewController release];
    
    [window addSubview: tabBarController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"GDNet_ImageOfTheDay" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"GDNet_ImageOfTheDay.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    //TODO delete something from DataManager
}


- (void)dealloc {
    
    [tabBarController release];
    [devMasterNavigationController release];
    [favouritesNavigationController release];
    [imagesNavigationController release];
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}


@end

