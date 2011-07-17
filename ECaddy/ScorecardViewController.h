//
//  ScorecardViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@class Course;

@interface ScorecardViewController : UIViewController <ADBannerViewDelegate> {
    UIView* contentView;
    
    Course* courseObj;    
    id adView;
    BOOL adVisible;
}
@property (nonatomic, retain) IBOutlet UIView* contentView;

@property (nonatomic, retain) Course* courseObj;
@property (nonatomic, retain) id adView;
@property (nonatomic) BOOL adVisible;

- (IBAction)startClicked:(id)sender;
- (IBAction)continueClicked:(id)sender;
- (IBAction)viewClicked:(id)sender;

- (void) startNewRoundWithCourseOrNil: (Course*) course;

- (void)createAdBannerView;
- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;

@end