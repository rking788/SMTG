//
//  ScorecardViewController.h
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/ADBannerView.h"

@class Course;

@interface ScorecardViewController : UIViewController <ADBannerViewDelegate, UIAlertViewDelegate> {
    UIView* contentView;
    UIActivityIndicatorView *uploadingInd;
    
    NSMutableArray* pendingCourses;
    Course* courseObj;
    id adView;
    BOOL adVisible;
    UIView *uploadingView;
}
@property (nonatomic, strong) IBOutlet UIView *uploadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uploadingInd;
@property (nonatomic, strong) IBOutlet UIView* contentView;

@property (nonatomic, strong) NSMutableArray* pendingCourses;
@property (nonatomic, strong) Course* courseObj;
@property (nonatomic, strong) id adView;
@property (nonatomic) BOOL adVisible;

- (IBAction)startClicked:(id)sender;
- (IBAction)continueClicked:(id)sender;
- (IBAction)viewClicked:(id)sender;

- (void) startNewRoundWithCourseOrNil: (Course*) course;

#ifdef LITE
- (void)createAdBannerView;
- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
#endif

- (void) checkForPending;
- (void) uploadCourses;
- (void) uploadCourseToServer: (Course*) course;
- (void) doneUploading;

@end