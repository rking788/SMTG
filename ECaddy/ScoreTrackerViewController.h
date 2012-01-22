//
//  ScoreTrackerViewController.h
//  SMTG
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class SMTGAppDelegate;
@class Course;
@class Scorecard;
@class HeaderFooterView;
@class Facebook;

@interface ScoreTrackerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, 
                                                            UIActionSheetDelegate, UIAlertViewDelegate, FBSessionDelegate, 
                                                            FBDialogDelegate, FBRequestDelegate>{
    HeaderFooterView *scoreHeaderView;
    HeaderFooterView *scoreFooterView;
                                                                UIView *titleView;
    UILabel *titleTextView;
    UILabel *dateLbl;
    UIButton *favstarBtn;
    UITableView *tableV;
    UIImageView *backgroundImageView;
    
    SMTGAppDelegate* appDel;
    Scorecard* scorecard;
    
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

@property (nonatomic, strong) IBOutlet HeaderFooterView *scoreHeaderView;
@property (nonatomic, strong) IBOutlet HeaderFooterView *scoreFooterView;
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UILabel *titleTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (nonatomic, strong) IBOutlet UIButton *favstarBtn;
@property (nonatomic, strong) IBOutlet UITableView *tableV;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) SMTGAppDelegate* appDel;
@property (nonatomic, strong) Scorecard* scorecard;

@property (nonatomic, unsafe_unretained) UITextField* activeField;

@property (nonatomic, strong) NSMutableDictionary* scorecardDict;

// Facebook properties
@property (readonly) Facebook* FB; 
@property (nonatomic, strong) NSArray* FBpermissions;
@property (nonatomic, getter = isFBLoggedIn) BOOL FBLoggedIn;
@property (nonatomic, strong) NSString* pendingFBAction;

- (IBAction)favstarPressed:(id)sender;

- (void) nameChangedFrom: (NSString*) oldName To: (NSString*) newName;
- (NSString*) stringForScoreWithRow: (NSUInteger) row AndCol: (NSUInteger) col;
- (void) setViewMovedUp: (BOOL) movedUp;

+ (NSUInteger) tagFromRow: (NSUInteger) row AndCol: (NSUInteger) col;
+ (NSArray*) rowAndColFromTag: (NSUInteger) tag;

- (void)registerForKeyboardNotifications;

- (void) actionButtonClicked: (id) sender;

- (void) saveScorecardImg;

+ (BOOL) savePNGForView:(UIView *)targetView rect:(CGRect)rect fileName:(NSString *)fileName;

// Facebook Methods
- (void) login;
- (void) logout;
- (void) uploadSCToFB;
#if 0
- (void)publishStream;
#endif
- (void)uploadPhoto;


@end
