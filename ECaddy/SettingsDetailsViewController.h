//
//  SettingsDetailsViewController.h
//  ECaddy
//
//  Created by Teacher on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

    SettingsViewController* delVC;
    UITableView* delTV;
    NSInteger detailType;
    NSManagedObjectContext* manObjCon;
    
    NSString* curName;
    
    NSMutableArray* locObjs;
    NSMutableDictionary* stateArrDict;
    NSDictionary* abbrsDict;
}

@property (nonatomic, assign) SettingsViewController* delVC;
@property (nonatomic, assign) UITableView* delTV;
@property (nonatomic, assign) NSInteger detailType;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

// Properties for the NameEdit detail type
@property (nonatomic, retain) NSString* curName;

// Properties for state visibility view
@property (nonatomic, retain) NSMutableArray* locObjs;
@property (nonatomic, retain) NSMutableDictionary* stateArrDict;
@property (nonatomic, retain) NSDictionary* abbrsDict;

// Methods for initialization based on the setting selected
- (void) nameEditInit;

// Methods for the state visibility settings details
- (void) fillStatesCountries;

- (void) switchToggled: (id) sender;
- (void) allSwitchesOnOff: (BOOL) on;
- (void) toggleMOEWithStateAbbr: (NSString*) abbr ToState: (BOOL) on;

- (NSString*) stateNameWithAbbr: (NSString*) abbr;
- (NSString*) stateAbbrWithName: (NSString*) name;

// Methods for Navigation bar button actions
- (void) cancel;
- (void) save;

@end
