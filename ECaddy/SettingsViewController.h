//
//  SettingsViewController.h
//  ECaddy
//
//  Created by RKing on 6/16/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseSelectViewController.h"

typedef enum _tagsectitleind
{
    kUSER_SEC = 0,
    kCOURSE_SEC,
    numSectTitles
} sectitleind;

typedef enum _taguserprefs
{
    kNAME = 0,
    numUserPrefs
} usertitles;

typedef enum _tagcourseprefs
{
    kCOURSE = 0,
    kSTATE,
    kVISIBILITY,
    numCoursePrefs
} coursetitles;

typedef enum _tagdictindexes
{
    kTITLE = 0,
    kDEF_VALUE,
    numDictValueSize
} dictindexes;

@interface SettingsViewController : UITableViewController <CourseSelectDelegate>{
    NSUserDefaults* defs;
    
    NSMutableArray* sectionTitles;
    NSMutableDictionary* userPrefsDict;
    NSMutableDictionary* coursePrefsDict;
    
    NSInteger selectedSettingsDetail;
}
@property (nonatomic, retain) NSUserDefaults* defs;

@property (nonatomic, retain) NSMutableArray* sectionTitles;
@property (nonatomic, retain) NSMutableDictionary* userPrefsDict;
@property (nonatomic, retain) NSMutableDictionary* coursePrefsDict;

@property (nonatomic, assign) NSInteger selectedSettingsDetail;

// Initialization functions
- (void) setupSectionTitles;
- (void) setupUserPrefs;
- (void) setupCoursePrefs;

// Helper functions
- (NSString*) keyForIndex: (NSInteger) index InSection:(NSInteger) sec;
- (NSInteger) indexForKey: (NSString*) key;

// Settings Details Functions
- (void) saveState: (NSString*) state;
- (void) saveDetailsWithTableView:(UITableView*) tv WithVC: (UIViewController*) vc;
- (void) cancelDetailsWithVC: (UIViewController*) vc;

@end
