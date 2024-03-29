//
//  DirectoryViewController.h
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CourseSelectViewController.h"

@class SMTGAppDelegate;

@interface DirectoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
 
    NSArray* sortedCountries;
    
    NSSet* stateSet;
    NSSet* countrySet;
    
    NSMutableArray* favoriteNames;
    NSMutableArray* favoriteLocs;
    
    NSDictionary* abbrsDict;
    NSDictionary* stateArrDict;
    NSManagedObjectContext* manObjCon;
  
    BOOL modal;
    
    SMTGAppDelegate* appDel;
    
    id<CourseSelectDelegate> __unsafe_unretained courseSelectDelegate;
   
    UITableView *theTable;
    
    // Property used to determine what field to pick in settings tab
    NSInteger settingsDetailType;
}

@property (nonatomic, strong) NSArray* sortedCountries;

@property (nonatomic, strong) NSMutableArray* favoriteNames;
@property (nonatomic, strong) NSMutableArray* favoriteLocs;
@property (nonatomic, strong) NSDictionary* abbrsDict;
@property (nonatomic, strong) NSDictionary* stateArrDict;
@property (nonatomic, strong) NSManagedObjectContext* manObjCon;

@property (nonatomic, strong) SMTGAppDelegate* appDel;

@property (nonatomic, unsafe_unretained) id<CourseSelectDelegate> courseSelectDelegate;

@property (nonatomic, strong) IBOutlet UITableView *theTable;

@property (nonatomic, assign, getter = isModal) BOOL modal;

@property (nonatomic, assign) NSInteger settingsDetailType;

- (void) fillStatesCountries;
- (void) fillFavorites;
- (void) modalCancel: (id) sender;
- (void) gotoCourseSelectWithState: (NSString*) stateName AndCountry:(NSString*) countryName Animate: (BOOL) animate;
- (void) courseCreateModal;


+ (NSString*) stateLNInAbbrs:(NSDictionary*) abbrs WithCSN: (NSString*) cShortN WithSSN: (NSString*) shortN;
+ (NSString*) stateSNInAbbrs:(NSDictionary*) abbrs WithCSN: (NSString*) shortCN WithSLN: (NSString*) longSN;
+ (NSString*) countryLNInAbbrs:(NSDictionary*) abbrs WithSN: (NSString*) shortN;
+ (NSString*) countrySNInAbbrs:(NSDictionary*) abbrs WithLN:(NSString*) longN;

@end
