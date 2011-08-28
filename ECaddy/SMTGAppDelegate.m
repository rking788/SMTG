//
//  SMTGAppDelegate.m
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "SMTGAppDelegate.h"
#import "DirectoryViewController.h"
#import "Course.h"

#pragma mark - TODO APPWIDE: Provide better support for different device orientations

// Include this to initliaze the database
//#import "dbinit.h"

@implementation SMTGAppDelegate

@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;
@synthesize curCourse, curScorecard;
@synthesize FB = _FB;
@synthesize defaultPrefs;
@synthesize lastUpdateStr;

// Constant for the database file name
NSString* const DBFILENAME = @"SMTG.sqlite";

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
    
    [self setDefaultPrefs: [NSUserDefaults standardUserDefaults]];
    
    [self findActiveScorecard];
    
    _FB = nil;
    
    // Check the server for new course information
    // Do the weather processing in another thread
    [NSThread detachNewThreadSelector: @selector(checkServerForCourses) 
                             toTarget: self withObject:nil];
    
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
    NSLog(@"Entered Background");
    [self saveContext];
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
    [self findActiveScorecard];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSLog(@"Will Terminate");
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [curCourse release];
    [curScorecard release];
    [defaultPrefs release];
    [lastUpdateStr release];
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
        NSLog(@"Failed to create the persistent store in SMTGAppDelegate");
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
    NSError* err = nil;
    
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
    NSManagedObjectContext* manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
    
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

- (void) saveCurScorecard:(NSMutableDictionary *)sc
{
    if(!sc){
        return ;
    }
    
    NSDictionary* newScores = [[NSDictionary alloc] initWithObjects: [sc allValues] forKeys: [sc allKeys]];
    self.curScorecard.scores = newScores;
    
    [self saveContext];
}

+ (SMTGAppDelegate*) sharedAppDelegate
{
    return (SMTGAppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (void) checkServerForCourses
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSDate* lastScanDate = [self.defaultPrefs objectForKey: @"LastCourseUpdate"];
    NSDateFormatter* dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat: @"yyyy-MM-dd"];
    
    [self setLastUpdateStr: [dateformatter stringFromDate: lastScanDate]];
    
    NSURLResponse* resp = nil;
    NSError* err = nil;
    
    // Add the course information into the POST request content
    NSURL* url = [NSURL URLWithString:@"http://mainelyapps.com/SMTG/FetchCourseUpdates.php"];
    NSString* content = [NSString stringWithFormat: @"op=check&date=%@", self.lastUpdateStr];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [content dataUsingEncoding: NSUTF8StringEncoding]];
    
    // TODO: This should probably be an asynchronous request to not hold up the UI
    NSData* ret = [NSURLConnection sendSynchronousRequest: request returningResponse: &resp error: &err];
    NSString* retStr = [[NSString alloc] initWithData: ret encoding: NSUTF8StringEncoding];
    
    // Check if there were any new courses or not
    if(![retStr isEqualToString: @"0\n"]){
        NSString* message = [NSString stringWithFormat: @"New information for %@ courses is available. Update Now? (Will run in the background)", retStr];
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"New Course Data" message: message delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
        
        [av show];
        [av release];
    }
    
    [retStr release];
    [request release];
    [dateformatter release];
    [pool release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString: @"Yes"]){
        // User clicked yes so go download the new course data
        [NSThread detachNewThreadSelector: @selector(downloadCourseInfo) 
                                 toTarget: self withObject:nil];
    }
}

- (void) downloadCourseInfo
{
    // TODO: Finish implementing the code to download all of the new courses and merge them into the 
    // SQLite store.
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURLResponse* resp = nil;
    NSError* err = nil;
    
    // Add the course information into the POST request content
    NSURL* url = [NSURL URLWithString:@"http://mainelyapps.com/SMTG/FetchCourseUpdates.php"];
    NSString* content = [NSString stringWithFormat: @"op=download&date=%@", self.lastUpdateStr];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [content dataUsingEncoding: NSUTF8StringEncoding]];
    
    // TODO: This should probably be an asynchronous request to not hold up the UI
    NSData* ret = [NSURLConnection sendSynchronousRequest: request returningResponse: &resp error: &err];
    NSString* retStr = [[NSString alloc] initWithData: ret encoding: NSASCIIStringEncoding];
    
    // Check if there were any new courses or not
    if([retStr isEqualToString: @""])
        return;
    
    [request release];
    
    // Get an array of the new courses
    NSArray* newCoursesArr = [retStr componentsSeparatedByString: @"\n"];
    NSCharacterSet* badChars = [NSCharacterSet characterSetWithCharactersInString: @"*"];
    
    [retStr release];
    
    // The course lines are in the form
    // courseName;address;phoneNumber;website;woeid;state;country;numHoles;mensPars;womensPars;teeCoords;greenCoords;\n
    for(NSString* courseLine in newCoursesArr){
        NSArray* cComps = [courseLine componentsSeparatedByString: @";"];
        
        if ([cComps count] == 1) {
            continue;
        }
        
        Course* tempCourse = [[Course alloc] initWithEntity: [NSEntityDescription entityForName:@"Course" inManagedObjectContext: self.managedObjectContext] insertIntoManagedObjectContext: nil];
        
        [tempCourse setCoursename: [cComps objectAtIndex: 0]];
        [tempCourse setValue: [cComps objectAtIndex: 1] forKey: @"address"];
        [tempCourse setPhone: [cComps objectAtIndex: 2]];
        if([[cComps objectAtIndex: 3] isEqualToString: @"NULL"])
            [tempCourse setWebsite: nil];
        else
            [tempCourse setWebsite: [cComps objectAtIndex: 3]];
        [tempCourse setWoeid: [cComps objectAtIndex: 4]];
        [tempCourse setValue: [cComps objectAtIndex: 5] forKey: @"state"];
        [tempCourse setValue: [cComps objectAtIndex: 6] forKey: @"country"];
        [tempCourse setNumholes: [NSNumber numberWithInt: [[cComps objectAtIndex: 7] intValue]]];
        
        NSString* tmpMenPars = [cComps objectAtIndex: 8];
        if([tmpMenPars isEqualToString: @"NULL"] || [tmpMenPars isEqualToString: @""])
            [tempCourse setMenpars: nil];
        else{
            tmpMenPars = [tmpMenPars stringByTrimmingCharactersInSet: badChars];
            [tempCourse setMenpars: [tmpMenPars componentsSeparatedByString:@","]];
        }
        
        NSString* tmpWomenPars = [cComps objectAtIndex: 9];
        if([tmpWomenPars isEqualToString: @"NULL"] || [tmpWomenPars isEqualToString: @""])
            [tempCourse setWomenpars: nil];
        else{
            tmpWomenPars = [tmpWomenPars stringByTrimmingCharactersInSet: badChars];
            [tempCourse setWomenpars: [tmpWomenPars componentsSeparatedByString:@","]];
        }
        
        NSString* tmpTeeCoords = [cComps objectAtIndex: 10];
        if([tmpTeeCoords isEqualToString: @"NULL"] || [tmpTeeCoords isEqualToString: @""])
            [tempCourse setTeeCoords: nil];
        else
            [tempCourse setTeeCoords: [tmpTeeCoords componentsSeparatedByString:@"*"]];
        
        NSString* tmpGreenCoords = [cComps objectAtIndex: 11];
        if([tmpGreenCoords isEqualToString: @"NULL"] || [tmpGreenCoords isEqualToString: @""])
            [tempCourse setGreenCoords: nil];
        else
            [tempCourse setGreenCoords: [tmpGreenCoords componentsSeparatedByString:@"*"]];
        
        [self updateOrAddCourse: tempCourse];
        
        [tempCourse release];
    }
    
    // Just updated the courses so set the last course update as today's date
    NSDate* lastScanDate = [NSDate date];
    [self.defaultPrefs setObject: lastScanDate forKey: @"LastCourseUpdate"];
    NSDateFormatter* dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat: @"yyyy-MM-dd"];
    
    [self setLastUpdateStr: [dateformatter stringFromDate: lastScanDate]];
    
    [dateformatter release];
    [pool release];
}

- (void) updateOrAddCourse:(Course *)newC
{
    // See if course is already on the phone
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext: self.managedObjectContext];
    [fetchrequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(coursename == %@) AND (state == %@) AND (country == %@)"
                              , newC.coursename, [newC valueForKey: @"state"], [newC valueForKey: @"country"]];
    [fetchrequest setPredicate:predicate];

    [fetchrequest setFetchLimit: 1];
    
    NSError *error = nil;
    Course* course = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchrequest error:&error];
    
    if (array != nil) {
        if([array count] > 0){
            course = [array objectAtIndex: 0];
        }
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    if(!course){
        // Add the new course into the persistent store
        course = [NSEntityDescription insertNewObjectForEntityForName: @"Course" inManagedObjectContext: self.managedObjectContext];
        
        // The enabled value needs to be set first, if it is not then the stateEnabled function will return the
        // new course being inserted which will have a value of nil for the enabled value and consequently set 
        // the value to NO
        [course setValue: [NSNumber numberWithBool: [self stateEnabled: [newC valueForKey:@"state"]]] forKey: @"enabled"];
        [course setCoursename: newC.coursename];
        [course setValue: [newC valueForKey: @"state"] forKey: @"state"];
        [course setValue: [newC valueForKey: @"country"] forKey: @"country"];
        [course setFavorite: [NSNumber numberWithBool: NO]];
        [course setPending: [NSNumber numberWithBool: NO]];
    }
    
    [course setValue: [newC valueForKey: @"address"] forKey: @"address"];
    [course setPhone: newC.phone];
    [course setWebsite: newC.website];
    [course setWoeid: newC.woeid];
    [course setNumholes: newC.numholes];
    [course setMenpars: newC.menpars];
    [course setWomenpars: newC.womenpars];
    [course setTeeCoords: newC.teeCoords];
    [course setGreenCoords: newC.greenCoords];
    
    // Save the context
    [self saveContext];
    
    [fetchrequest release];
    
}

- (BOOL) stateEnabled:(NSString *)stateStr
{
    BOOL ret = YES;
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext: self.managedObjectContext];
    [fetchrequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"state == %@", stateStr];
    [fetchrequest setPredicate:predicate];
    
    [fetchrequest setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        if([array count] > 0){
            ret = [(NSNumber*)[[array objectAtIndex: 0] valueForKey: @"enabled"] boolValue];
        }
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];
    
    return ret;
}

#ifdef LITE
- (NSUInteger) findNumSCs
{
    NSUInteger ret = 0;
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext: self.managedObjectContext];
    [fetchrequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        ret = [array count];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];

    return ret;
}

- (void) removeOldestSC
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext: self.managedObjectContext];
    [fetchrequest setEntity:entity];
    
    [fetchrequest setFetchLimit: 1];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"dateplayed" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        if([array count] != 0){
            [self.managedObjectContext deleteObject: [array objectAtIndex: 0]];
            [self saveContext];
        }
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [sdArr release];
    [sortDescript release];
    [fetchrequest release];
}

#endif

#pragma mark - Facebook methods
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.FB handleOpenURL:url];
}

- (void) setFBInstance: (Facebook*) fb
{
    _FB = fb;
}

@end
