//
//  WeatherDetails.h
//  ECaddy
//
//  Created by RKing on 4/28/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeatherDetails : UIViewController {
    NSString* text;
    NSString* courseName;
    NSString* courseLoc;
    NSString* WOEID;
    UIActivityIndicatorView *actIndicator;
    
    UINavigationBar *navBar;
    
    UIImageView *weatherPic;
    
    UILabel *courseDetailsLbl;
    
    UITextView *curWeatherTV;
    UITextView *todayForecastTV;
    UITextView *nextDayForecastTV;
}
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* courseName;
@property (nonatomic, retain) NSString* courseLoc;
@property (nonatomic, retain) NSString* WOEID;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndicator;

@property (nonatomic, retain) IBOutlet UITextView *curWeatherTV;
@property (nonatomic, retain) IBOutlet UITextView *todayForecastTV;
@property (nonatomic, retain) IBOutlet UITextView *nextDayForecastTV;

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIImageView *weatherPic;
@property (nonatomic, retain) IBOutlet UILabel *courseDetailsLbl;

- (void) cancel;
- (void) getWeatherInfo;
- (void) setWeatherInfo;

@end
