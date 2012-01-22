//
//  DefaultUnitsViewController.h
//  SMTG
//
//  Created by Robert King on 9/18/11.
//  Copyright 2011 University of Maine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _tagrowtitleinds
{
    kTEMP = 0,
    kDISTANCE,
    kSPEED,
    numRowTitles
} rowtitleinds;


@interface DefaultUnitsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>{
    
    UITableView *tableV;
    UINavigationBar *navBar;

    NSMutableDictionary* unitsDict;
    NSUserDefaults* defs;
    
    UIActionSheet* actSheet;
    NSMutableArray* pickerOptsArr;
    
    NSUInteger lastSelRow;
}

@property (nonatomic, strong) IBOutlet UITableView *tableV;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

@property (nonatomic, strong) NSMutableDictionary* unitsDict;
@property (nonatomic, strong) NSUserDefaults* defs;

@property (nonatomic, strong) UIActionSheet* actSheet;
@property (nonatomic, strong) NSMutableArray* pickerOptsArr;

@property (nonatomic, assign) NSUInteger lastSelRow;

- (void) cancel;
- (void) save;

- (void) initUnitsDict;
- (NSString*) keyForIndex: (NSUInteger) index;

- (void) showPickerViewForIndexPath: (NSIndexPath*) indPath;
- (void) dismissPickerView;

@end
