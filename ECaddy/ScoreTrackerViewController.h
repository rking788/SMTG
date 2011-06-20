//
//  ScoreTrackerViewController.h
//  ECaddy
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scorecard.h"
#import "Course.h"
#import "HeaderFooterView.h"

@interface ScoreTrackerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    Scorecard* scorecard;
    UITextView *titleTextView;
    UIButton *favstarBtn;
    HeaderFooterView *scoreHeaderView;
    HeaderFooterView *scoreFooterView;
    NSMutableDictionary* scorecardDict;
    UIButton *saveCurSC;
}

enum{
    HOLENUM_TAG = 20,
    PAR_TAG
};

@property (nonatomic, retain) IBOutlet HeaderFooterView *scoreHeaderView;
@property (nonatomic, retain) IBOutlet HeaderFooterView *scoreFooterView;
@property (nonatomic, retain) IBOutlet UITextView *titleTextView;
@property (nonatomic, retain) IBOutlet UIButton *favstarBtn;

@property (nonatomic, retain) NSMutableDictionary* scorecardDict;
@property (nonatomic, retain) Scorecard* scorecard;

- (IBAction)favstarPressed:(id)sender;

- (void) nameChangedFrom: (NSString*) oldName To: (NSString*) newName;
- (NSString*) stringForScoreWithRow: (NSUInteger) row AndCol: (NSUInteger) col;

+ (NSUInteger) tagFromRow: (NSUInteger) row AndCol: (NSUInteger) col;
+ (NSArray*) rowAndColFromTag: (NSUInteger) tag;

@end
