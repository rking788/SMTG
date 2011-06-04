//
//  NewRoundViewController.h
//  ECaddy
//
//  Created by RKing on 6/2/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseSelectViewController.h"

typedef enum _tagTableRows
{
    kCourseName = 0,
    kNumPlayers,
    numTableRows
} TableRows;

@interface NewRoundViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, CourseSelectDelegate> {
    UIActionSheet* actSheet;
    Course* curCourse;
}

@property (nonatomic, retain) UIActionSheet* actSheet;
@property (nonatomic, retain) Course* curCourse;

- (void) showPickerView;
- (void) dismissPickerView;

@end
