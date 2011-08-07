//
//  NewRoundViewController.h
//  ECaddy
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
    UITableView *tableView;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIActionSheet* actSheet;
@property (nonatomic, retain) Course* curCourse;
@property (nonatomic, retain) Scorecard* curScorecard;

- (Course*) loadDefaultCourse;
- (void) showPickerView;
- (void) dismissPickerView;
- (void) beginClicked;
- (void) beginRound;
- (void) resumeRound;
- (void) gotoScoreTrackerWithSC: (Scorecard*) sc;

@end
