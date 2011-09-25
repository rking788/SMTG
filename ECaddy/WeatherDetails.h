//
//  WeatherDetails.h
//  SMTG
//
//  Created by RKing on 4/28/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"

@interface WeatherDetails : UIViewController {
    Course* courseObj;
    
    NSString* text;
    NSString* courseName;
    NSString* courseLoc;
    NSString* WOEID;
    
    UINavigationBar *navBar;
    UIActivityIndicatorView *actIndicator;
    
    // Top level views with borders
    UIView *titleView;
    UIView *ywiView;
    UIView *currentView;
    UIView *todayView;
    UIView *tomView;
    
    // Title view
    UILabel *courseDetailsLbl;
    UIButton *favstarBtn;
    
    // Current weather view
    UILabel *curWind;
    UILabel *curText;
    UILabel *tempLbl;
    UILabel *sunriseLbl;
    UILabel *sunsetLbl;
    UIImageView *windArrowImg;
    UIImageView *weatherPic;
    
    // Today's forecast
    UILabel *todayText;
    UILabel *todayHigh;
    UILabel *todayLow;
    
    // Tomorrow's forecast
    UILabel *tomText;
    UILabel *tomHigh;
    UILabel *tomLow;
    
    UIView *errorView;
    UIImageView *yahooWeatherImg;
    UIImageView *backgroundImg;
}
@property (nonatomic, retain) Course* courseObj;

@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* courseName;
@property (nonatomic, retain) NSString* courseLoc;
@property (nonatomic, retain) NSString* WOEID;

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndicator;

// Top Level Views (with borders)
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UIView *ywiView;
@property (nonatomic, retain) IBOutlet UIView *currentView;
@property (nonatomic, retain) IBOutlet UIView *todayView;
@property (nonatomic, retain) IBOutlet UIView *tomView;

// Title View
@property (nonatomic, retain) IBOutlet UIButton *favstarBtn;
@property (nonatomic, retain) IBOutlet UILabel *courseDetailsLbl;

// Current Conditions
@property (nonatomic, retain) IBOutlet UILabel *curWind;
@property (nonatomic, retain) IBOutlet UILabel *curText;
@property (nonatomic, retain) IBOutlet UILabel *tempLbl;
@property (nonatomic, retain) IBOutlet UILabel *sunriseLbl;
@property (nonatomic, retain) IBOutlet UILabel *sunsetLbl;
@property (nonatomic, retain) IBOutlet UIImageView *weatherPic;
@property (nonatomic, retain) IBOutlet UIImageView *windArrowImg;

// Today's Forecast
@property (nonatomic, retain) IBOutlet UILabel *todayText;
@property (nonatomic, retain) IBOutlet UILabel *todayHigh;
@property (nonatomic, retain) IBOutlet UILabel *todayLow;

// Tomorrow's Forecast
@property (nonatomic, retain) IBOutlet UILabel *tomText;
@property (nonatomic, retain) IBOutlet UILabel *tomHigh;
@property (nonatomic, retain) IBOutlet UILabel *tomLow;

@property (nonatomic, retain) IBOutlet UIView *errorView;
@property (nonatomic, retain) IBOutlet UIImageView *yahooWeatherImg;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImg;

- (IBAction)favstarPressed:(id)sender;

- (void) cancel;
- (void) getWeatherInfo;
- (void) setWeatherInfo;

+ (NSString*) MPHtoKMH: (NSString*) mphSpeed;
+ (NSString*) KMHtoMPH: (NSString*) kmhSpeed;

@end
