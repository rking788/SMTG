//
//  ScoreTrackerViewController.h
//  ECaddy
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class ECaddyAppDelegate;
@class Course;
@class Scorecard;
@class HeaderFooterView;
@class Facebook;

@interface ScoreTrackerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {
    ECaddyAppDelegate* appDel;
    Scorecard* scorecard;
    
    UITextView *titleTextView;
    UIButton *favstarBtn;
    UITableView *tableV;
    
    HeaderFooterView *scoreHeaderView;
    HeaderFooterView *scoreFooterView;
    NSMutableDictionary* scorecardDict;
    UIButton *saveCurSC;
    
    Facebook* _FB;
    NSArray* FBpermissions;
    BOOL FBLoggedIn;
}

enum{
    HOLENUM_TAG = 20,
    PAR_TAG
};
@property (nonatomic, retain) ECaddyAppDelegate* appDel;
@property (nonatomic, retain) Scorecard* scorecard;

@property (nonatomic, retain) IBOutlet HeaderFooterView *scoreHeaderView;
@property (nonatomic, retain) IBOutlet HeaderFooterView *scoreFooterView;
@property (nonatomic, retain) IBOutlet UITextView *titleTextView;
@property (nonatomic, retain) IBOutlet UIButton *favstarBtn;
@property (nonatomic, retain) IBOutlet UITableView *tableV;

@property (nonatomic, assign) UITextField* activeField;

@property (nonatomic, retain) NSMutableDictionary* scorecardDict;

// Facebook properties
@property (readonly) Facebook* FB; 
@property (nonatomic, retain) NSArray* FBpermissions;
@property (nonatomic, getter = isFBLoggedIn) BOOL FBLoggedIn;

- (IBAction)favstarPressed:(id)sender;

- (void) nameChangedFrom: (NSString*) oldName To: (NSString*) newName;
- (NSString*) stringForScoreWithRow: (NSUInteger) row AndCol: (NSUInteger) col;
- (void) setViewMovedUp: (BOOL) movedUp;

+ (NSUInteger) tagFromRow: (NSUInteger) row AndCol: (NSUInteger) col;
+ (NSArray*) rowAndColFromTag: (NSUInteger) tag;

- (void)registerForKeyboardNotifications;

// Facebook Methods
- (void) login;
- (void) logout;
- (void) FBButtonClicked: (id) sender;
- (void)publishStream;
- (void)uploadPhoto;


@end
