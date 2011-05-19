//
//  WeatherDetails.h
//  ECaddy
//
//  Created by Teacher on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeatherDetails : UIViewController {
    NSString* text;
    NSString* courseName;
    NSString* courseLoc;
    
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

@property (nonatomic, retain) IBOutlet UITextView *curWeatherTV;
@property (nonatomic, retain) IBOutlet UITextView *todayForecastTV;
@property (nonatomic, retain) IBOutlet UITextView *nextDayForecastTV;

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIImageView *weatherPic;
@property (nonatomic, retain) IBOutlet UILabel *courseDetailsLbl;

- (void) cancel;
- (void) setWeatherInfo;

@end
