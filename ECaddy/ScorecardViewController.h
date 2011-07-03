//
//  ScorecardViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "iAd/ADBannerView.h"

@interface ScorecardViewController : UIViewController {
    Course* courseObj;
    ADBannerView* adView;
}
@property (nonatomic, retain) IBOutlet ADBannerView* adView;

@property (nonatomic, retain) Course* courseObj; 

- (IBAction)startClicked:(id)sender;
- (IBAction)continueClicked:(id)sender;
- (IBAction)viewClicked:(id)sender;

- (void) startNewRoundWithCourseOrNil: (Course*) course;

@end
