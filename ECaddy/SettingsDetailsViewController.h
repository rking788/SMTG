//
//  SettingsDetailsViewController.h
//  SMTG
//
//  Created by RKing on 6/20/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SettingsViewController;

enum{
    kNAME_EDIT = 10,
    kCOURSE_EDIT,
    kSTATE_EDIT,
    kSTATE_VISIBILITY
};

enum{
    kNAVBAR_TAG = 70,
    kNAMEEDIT_TAG = 77, 
    kVISTABLE_TAG = 78,
    kBASECELL_TAG = 100
};

@interface SettingsDetailsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {

    SettingsViewController* __unsafe_unretained delVC;
    UITableView* __unsafe_unretained delTV;
    NSInteger detailType;
    NSManagedObjectContext* manObjCon;
    
    NSString* curName;
    
    NSMutableArray* locObjs;
    NSArray* sortedCountries;
    NSMutableDictionary* stateArrDict;
    NSDictionary* abbrsDict;
}

@property (nonatomic, unsafe_unretained) SettingsViewController* delVC;
@property (nonatomic, unsafe_unretained) UITableView* delTV;
@property (nonatomic, assign) NSInteger detailType;
@property (nonatomic, strong) NSManagedObjectContext* manObjCon;

// Properties for the NameEdit detail type
@property (nonatomic, strong) NSString* curName;

// Properties for state visibility view
@property (nonatomic, strong) NSMutableArray* locObjs;
@property (nonatomic, strong) NSArray* sortedCountries;
@property (nonatomic, strong) NSMutableDictionary* stateArrDict;
@property (nonatomic, strong) NSDictionary* abbrsDict;

// Methods for initialization based on the setting selected
- (void) nameEditInit;

// Methods for the state visibility settings details
- (void) fillStatesCountries;
- (NSOrderedSet*) sortShortStates: (NSArray*) shortStateNames InCountry: (NSString*) shortCountry;
- (NSArray*) sortCountries: (NSArray*) countryLongNames;
+ (NSString*) stateSNInAbbrs:(NSDictionary*) abbrs WithCSN: (NSString*) shortCN WithSLN: (NSString*) longSN;
+ (NSString*) countrySNInAbbrs:(NSDictionary*) abbrsDict WithLN:(NSString*) longName;

- (void) switchToggled: (id) sender;
- (void) allSwitchesOnOff: (BOOL) on;
- (void) toggleMOEWithStateAbbr: (NSString*) abbr ToState: (BOOL) on;

// Methods for Navigation bar button actions
- (void) cancel;
- (void) save;

@end
