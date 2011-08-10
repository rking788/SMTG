//
//  SMTGAppDelegate.h
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Course.h"
#import "Scorecard.h"
#import "FBConnect.h"

# pragma mark - TODO Possibly try to reduce memory footprint for the entire app

@interface SMTGAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    Course* curCourse;
    Scorecard* curScorecard;
    NSUserDefaults* defaultPrefs;
    
    Facebook* _FB;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// Core Data related properties
@property (nonatomic, retain, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

// Properties related to the current round being played and the current scorecard for the round
@property (nonatomic, retain) Course* curCourse;
@property (nonatomic, retain) Scorecard* curScorecard;

@property (readonly) Facebook* FB;

- (NSString *)applicationDocumentsDirectory;
- (void) loadDefaultDB;

- (Scorecard*) startNewRoundWithCourse: (Course*) golfCourse withNPlayers: (NSNumber*) nPlayers;
- (Scorecard*) findActiveScorecard;

- (void) saveContext;

+ (SMTGAppDelegate*) sharedAppDelegate;

#ifdef LITE
- (NSUInteger) findNumSCs;
- (void) removeOldestSC;
#endif

- (void) setFBInstance: (Facebook*) fb;

@end
