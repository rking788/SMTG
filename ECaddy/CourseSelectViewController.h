//
//  CourseSelectViewController.h
//  SMTG
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Course.h"

@class SMTGAppDelegate;

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
    
    SMTGAppDelegate* appDel;
    
    id<CourseSelectDelegate> __unsafe_unretained courseSelectDelegate;
    
    BOOL searching;
    BOOL modal;
}
@property (nonatomic, strong) IBOutlet UISearchBar *searchB;
@property (nonatomic, strong) IBOutlet UITableView *tableV;
@property (nonatomic, strong) IBOutlet UIView *blackView;

@property (nonatomic, strong) NSMutableArray* arrayOfChars;
@property (nonatomic, strong) NSMutableDictionary* coursesDict; 
@property (nonatomic, strong) NSArray* nameSearch;
@property (nonatomic, strong) NSString* selectedState;
@property (nonatomic, strong) NSString* longStateName;
@property (nonatomic, strong) NSManagedObjectContext* manObjCon;
@property (nonatomic, strong) NSMutableArray* favoriteNames;
@property (nonatomic, strong) NSMutableArray* favoriteLocs;

@property (nonatomic, strong) SMTGAppDelegate* appDel;

@property (nonatomic, unsafe_unretained) id<CourseSelectDelegate> courseSelectDelegate;

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