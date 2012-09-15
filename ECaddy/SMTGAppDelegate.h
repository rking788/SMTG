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

@class MapViewController;

# pragma mark - TODO Possibly try to reduce memory footprint for the entire app

@interface SMTGAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
    Course* curCourse;
    Scorecard* curScorecard;
    NSUserDefaults* defaultPrefs;
    NSString* lastUpdateStr;
    
    MapViewController* mvcInst;
    
    BOOL gettingCourses;
    
    Facebook* __unsafe_unretained _FB;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *progressView;
@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *progressBar;

// Core Data related properties
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

// Properties related to the current round being played and the current scorecard for the round
@property (nonatomic, strong) Course* curCourse;
@property (nonatomic, strong) Scorecard* curScorecard;

@property (nonatomic, strong) NSUserDefaults* defaultPrefs;
@property (nonatomic, strong) NSString* lastUpdateStr;

@property (strong, atomic) MapViewController* mvcInst;
@property (assign, nonatomic, getter = isGettingSports) BOOL gettingCourses;

@property (readonly, unsafe_unretained) Facebook* FB;

- (NSString *)applicationDocumentsDirectory;
- (void) loadDefaultDB;

- (Scorecard*) startNewRoundWithCourse: (Course*) golfCourse withNPlayers: (NSNumber*) nPlayers;
- (Scorecard*) findActiveScorecard;

- (void) saveContext;

- (void) saveCurScorecard: (NSMutableDictionary*) sc;
+ (SMTGAppDelegate*) sharedAppDelegate;

- (void) displayAlertView: (UIAlertView*) av;

- (void) checkServerForCourses;
- (void) downloadCourseInfo;
- (void) updateOrAddCourse: (Course*) newC;
- (BOOL) stateEnabled: (NSString*) stateStr;

- (void) addProgressBarView;
- (void) animateProgressViewIn: (NSNumber*) show;
- (void) updateProgressBar: (NSNumber*) percent;

#ifdef LITE
- (NSUInteger) findNumSCs;
- (void) removeOldestSC;
#endif

- (void) setFBInstance: (Facebook*) fb;

@end
