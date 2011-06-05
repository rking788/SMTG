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

@protocol CourseSelectDelegate <NSObject>

- (void) selectCourse: (Course*) golfCourse;

@end

@interface CourseSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    // Original arrays
    NSMutableArray* courseNames;
    NSMutableArray* courseLocs;
    
    // Search arrays
    NSMutableArray* nameSearch;
    NSMutableArray* locsSearch;
    
    NSString* selectedState;
    NSManagedObjectContext* manObjCon;
    UISearchBar *searchBar;
    UITableView *tableV;
    UIView *blackView;
    
    id<CourseSelectDelegate> courseSelectDelegate;
    
    BOOL searching;
    BOOL modal;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableV;
@property (nonatomic, retain) IBOutlet UIView *blackView;

@property (nonatomic, retain) NSMutableArray* courseNames;
@property (nonatomic, retain) NSMutableArray* courseLocs;
@property (nonatomic, retain) NSMutableArray* nameSearch;
@property (nonatomic, retain) NSMutableArray* locsSearch;
@property (nonatomic, retain) NSString* selectedState;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

@property (nonatomic, assign) id<CourseSelectDelegate> courseSelectDelegate;

@property (nonatomic, assign, getter = isSearching) BOOL searching;
@property (nonatomic, assign, getter = isModal) BOOL modal;

- (void) fillNamesAndLocs;
- (void) doneSearching_Clicked:(id)sender;
- (void) handleTapFrom: (UITapGestureRecognizer*) recognizer;
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText;
- (void) searchTableView;
- (void) modalCancel: (id) sender;

@end