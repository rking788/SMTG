//
//  SettingsViewController.h
//  SMTG
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
    kCONTACT_SEC,
    numSectTitles
} sectitleind;

typedef enum _taguserprefs
{
    kNAME = 0,
    kDEFUNITS,
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

typedef enum _tagcontactprefs
{
    kEMAIL = 0,
    kWEBSITE,
    numContactPrefs
} contactprefs;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CourseSelectDelegate, UIActionSheetDelegate>{
    NSUserDefaults* defs;
    
    NSMutableArray* sectionTitles;
    NSMutableDictionary* userPrefsDict;
    NSMutableDictionary* coursePrefsDict;
    NSMutableArray* contactPrefsArr;
    
    NSInteger selectedSettingsDetail;
    UITableView *tableV;
}
- (IBAction)getFullVersion:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *upgradeBtn;

@property (retain, nonatomic) IBOutlet UITableView *tableV;

@property (nonatomic, retain) NSUserDefaults* defs;

@property (nonatomic, retain) NSMutableArray* sectionTitles;
@property (nonatomic, retain) NSMutableDictionary* userPrefsDict;
@property (nonatomic, retain) NSMutableDictionary* coursePrefsDict;
@property (nonatomic, retain) NSMutableArray* contactPrefsArr;

@property (nonatomic, assign) NSInteger selectedSettingsDetail;

// Initialization functions
- (void) setupSectionTitles;
- (void) setupUserPrefs;
- (void) setupCoursePrefs;
- (void) setupContactPrefs;

// Helper functions
- (NSString*) keyForIndex: (NSInteger) index InSection:(NSInteger) sec;
- (NSInteger) indexForKey: (NSString*) key;

// Settings Details Functions
- (void) saveState: (NSString*) state AndCountry: (NSString*) country;
- (void) saveDetailsWithTableView:(UITableView*) tv WithVC: (UIViewController*) vc;
- (void) cancelDetailsWithVC: (UIViewController*) vc;

@end
