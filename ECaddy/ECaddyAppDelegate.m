//
//  ECaddyAppDelegate.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ECaddyAppDelegate.h"
#import "DirectoryViewController.h"

// Include this to initliaze the database
//#import "dbinit.h"

@implementation ECaddyAppDelegate

@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;
@synthesize curCourse, curScorecard;

// Constant for the database file name
NSString* const DBFILENAME = @"ECaddy.sqlite";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // Migrate the default DB if necessary
    [self loadDefaultDB];
    
    // Uncomment this to do database initialization
    //dbinit* dbInit = [[dbinit alloc] init];
    //[dbInit insertWOEIDS];
    //dbInit.manObjCon = [self managedObjectContext];
    //[dbInit fillDB];
    //[dbInit release];
    
    self.curCourse = nil;
    self.curScorecard = nil;
    
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
    [_tabBarController release];
    [curCourse release];
    [curScorecard release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/


#pragma mark Core Data property methods
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL* storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:DBFILENAME]];
    NSError *error = nil;
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Handle the error.
        NSLog(@"Failed to create the persistent store in ECaddyAppDelegate");
    }    
    
    return persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)loadDefaultDB{
    
    BOOL success;
    NSError* err;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* dbPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:DBFILENAME];
    
    success = [fm fileExistsAtPath:dbPath];
    
    // If the database exists then just return
    if(success){
        NSLog(@"DB File exists");
        return;
    }
    
    NSString* defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBFILENAME];
    
    // If there is a default database file copy it, if not then fail
    //if([fm fileExistsAtPath:defaultDBPath]){
    success = [fm copyItemAtPath:defaultDBPath toPath:dbPath error:&err];
    
    if(!success){
        NSLog(@"Failed to copy the default database");
        NSAssert1(0, @"Failed to copy the default DB with message '%@'.", [err localizedDescription]);
    }
    //  }
    // else{
    //    NSLog(@"Default database does not exist");
    //    NSAssert1(0, @"Default database file does not exist", nil);
    // }
    
}

- (Scorecard*) startNewRoundWithCourse: (Course*) golfCourse withNPlayers: (NSNumber*) nPlayers
{
    Scorecard* newScorecard;
    self.curCourse = golfCourse;
    
    //Create the new scorecard object to be entered into the database
    newScorecard = [NSEntityDescription insertNewObjectForEntityForName: @"Scorecard" inManagedObjectContext: self.managedObjectContext];
    newScorecard.course = golfCourse;

    // Initialize the date for the scorecard
    newScorecard.dateplayed = [NSDate date];
    newScorecard.active = [NSNumber numberWithBool: TRUE];
    newScorecard.numplayers = nPlayers;
    
    self.curScorecard = newScorecard;
    
    return newScorecard;
}

- (void) saveContext
{
    NSError* err;
    
    if(![self.managedObjectContext save:&err]){
        // Handle the error here
        NSLog(@"Failed to save the managedObjectContext");
    }
}

- (Scorecard*) findActiveScorecard
{
    NSPredicate* predicate = nil;
    
    // Should probably use the name of the default course here
    // Or at least the default state. A random golf course would be weird.
    NSManagedObjectContext* manObjCon = [[ECaddyAppDelegate sharedAppDelegate] managedObjectContext];
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext: manObjCon];
    [fetchrequest setEntity:entity];
    
    predicate = [NSPredicate predicateWithFormat:@"active == %@", [NSNumber numberWithBool: YES]];
    [fetchrequest setPredicate:predicate];
    
    [fetchrequest setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray *array = [manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        if([array count] != 0)
            self.curScorecard = [array objectAtIndex: 0];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];
    
    if(self.curScorecard)
        self.curCourse = self.curScorecard.course;
    
    return self.curScorecard;
}

+ (ECaddyAppDelegate*) sharedAppDelegate
{
    return (ECaddyAppDelegate*) [[UIApplication sharedApplication] delegate];
}

@end
