//
//  NewRoundViewController.h
//  SMTG
//
//  Created by RKing on 6/2/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseSelectViewController.h"

@class Scorecard;

typedef enum _tagTableRows
{
    kCourseName = 0,
    kNumPlayers,
    numTableRows
} TableRows;

@interface NewRoundViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CourseSelectDelegate, UIAlertViewDelegate> {
    UIActionSheet* actSheet;
    Course* curCourse;
    Scorecard* curScorecard;
    UITableView *tableV;
    UITextView *liteMessage;
}
- (IBAction)getFullVersion:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *liteFooterView;

@property (strong, nonatomic) IBOutlet UIButton *upgradeBtn;
@property (nonatomic, strong) IBOutlet UITextView *liteMessage;
@property (strong, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic, strong) UIActionSheet* actSheet;
@property (nonatomic, strong) Course* curCourse;
@property (nonatomic, strong) Scorecard* curScorecard;

- (Course*) loadDefaultCourse;
- (void) showPickerView;
- (void) dismissPickerView;
- (void) beginClicked;
- (void) beginRound;
- (void) resumeRound;
- (void) gotoScoreTrackerWithSC: (Scorecard*) sc;

@end
