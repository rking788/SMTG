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
@property (nonatomic, strong) Course* courseObj;

@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* courseName;
@property (nonatomic, strong) NSString* courseLoc;
@property (nonatomic, strong) NSString* WOEID;

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *actIndicator;

// Top Level Views (with borders)
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UIView *ywiView;
@property (nonatomic, strong) IBOutlet UIView *currentView;
@property (nonatomic, strong) IBOutlet UIView *todayView;
@property (nonatomic, strong) IBOutlet UIView *tomView;

// Title View
@property (nonatomic, strong) IBOutlet UIButton *favstarBtn;
@property (nonatomic, strong) IBOutlet UILabel *courseDetailsLbl;

// Current Conditions
@property (nonatomic, strong) IBOutlet UILabel *curWind;
@property (nonatomic, strong) IBOutlet UILabel *curText;
@property (nonatomic, strong) IBOutlet UILabel *tempLbl;
@property (nonatomic, strong) IBOutlet UILabel *sunriseLbl;
@property (nonatomic, strong) IBOutlet UILabel *sunsetLbl;
@property (nonatomic, strong) IBOutlet UIImageView *weatherPic;
@property (nonatomic, strong) IBOutlet UIImageView *windArrowImg;

// Today's Forecast
@property (nonatomic, strong) IBOutlet UILabel *todayText;
@property (nonatomic, strong) IBOutlet UILabel *todayHigh;
@property (nonatomic, strong) IBOutlet UILabel *todayLow;

// Tomorrow's Forecast
@property (nonatomic, strong) IBOutlet UILabel *tomText;
@property (nonatomic, strong) IBOutlet UILabel *tomHigh;
@property (nonatomic, strong) IBOutlet UILabel *tomLow;

@property (nonatomic, strong) IBOutlet UIView *errorView;
@property (nonatomic, strong) IBOutlet UIImageView *yahooWeatherImg;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImg;

- (IBAction)favstarPressed:(id)sender;

- (void) cancel;
- (void) getWeatherInfo;
- (void) setWeatherInfo;

+ (NSString*) MPHtoKMH: (NSString*) mphSpeed;
+ (NSString*) KMHtoMPH: (NSString*) kmhSpeed;

@end
