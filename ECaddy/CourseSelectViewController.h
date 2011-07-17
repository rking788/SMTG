//
//  CourseSelectViewController.h
//  ECaddy
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Course.h"

@class ECaddyAppDelegate;

enum{
    kNAME_SCOPE_INDEX,
    kLOC_SCOPE_INDEX
};

@protocol CourseSelectDelegate <NSObject>

- (void) selectCourse: (Course*) golfCourse;

@end

@interface CourseSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray* arrayOfChars;
    NSMutableDictionary* coursesDict;
    
    // Favorite arrays
    NSMutableArray* favoriteNames;
    NSMutableArray* favoriteLocs;
    
    // Search array (This array has a name and a location seperated by a ;
    NSArray* nameSearch;
    
    NSString* selectedState;
    NSString* longStateName;
    NSManagedObjectContext* manObjCon;
    UISearchBar *searchB;
    UITableView *tableV;
    UIView *blackView;
    
    ECaddyAppDelegate* appDel;
    
    id<CourseSelectDelegate> courseSelectDelegate;
    
    BOOL searching;
    BOOL modal;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchB;
@property (nonatomic, retain) IBOutlet UITableView *tableV;
@property (nonatomic, retain) IBOutlet UIView *blackView;

@property (nonatomic, retain) NSMutableArray* arrayOfChars;
@property (nonatomic, retain) NSMutableDictionary* coursesDict; 
@property (nonatomic, retain) NSArray* nameSearch;
@property (nonatomic, retain) NSString* selectedState;
@property (nonatomic, retain) NSString* longStateName;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;
@property (nonatomic, retain) NSMutableArray* favoriteNames;
@property (nonatomic, retain) NSMutableArray* favoriteLocs;

@property (nonatomic, retain) ECaddyAppDelegate* appDel;

@property (nonatomic, assign) id<CourseSelectDelegate> courseSelectDelegate;

@property (nonatomic, assign, getter = isSearching) BOOL searching;
@property (nonatomic, assign, getter = isModal) BOOL modal;

- (void) fillNamesAndLocs;
- (void) doneSearching_Clicked:(id)sender;
- (void) handleTapFrom: (UITapGestureRecognizer*) recognizer;
- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText;
- (void) searchTableView;
- (void) modalCancel: (id) sender;
- (void) fillFavorites;
- (void) courseCreateModal;

+ (Course*) courseObjectWithName: (NSString*) name InContext: (NSManagedObjectContext*) context;

@end