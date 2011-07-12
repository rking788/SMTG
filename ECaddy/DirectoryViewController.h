//
//  DirectoryViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CourseSelectViewController.h"

@interface DirectoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
 
    NSSet* stateSet;
    NSSet* countrySet;
    
    NSMutableArray* favoriteNames;
    NSMutableArray* favoriteLocs;
    
    NSDictionary* abbrsDict;
    NSDictionary* stateArrDict;
    NSManagedObjectContext* manObjCon;
  
    BOOL modal;
    
    id<CourseSelectDelegate> courseSelectDelegate;
    UITableView *theTable;
    
    // Property used to determine what field to pick in settings tab
    NSInteger settingsDetailType;
}
@property (nonatomic, retain) NSSet* stateSet;
@property (nonatomic, retain) NSSet* countrySet;
@property (nonatomic, retain) NSMutableArray* favoriteNames;
@property (nonatomic, retain) NSMutableArray* favoriteLocs;
@property (nonatomic, retain) NSDictionary* abbrsDict;
@property (nonatomic, retain) NSDictionary* stateArrDict;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;
@property (nonatomic, assign) id<CourseSelectDelegate> courseSelectDelegate;

@property (nonatomic, retain) IBOutlet UITableView *theTable;

@property (nonatomic, assign, getter = isModal) BOOL modal;

@property (nonatomic, assign) NSInteger settingsDetailType;

- (void) fillStatesCountries;
- (void) fillFavorites;
- (void) modalCancel: (id) sender;
- (void) gotoCourseSelectWithState: (NSString*) stateAbbr Animate: (BOOL) animate;
- (void) courseCreateModal;

@end
