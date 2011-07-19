//
//  WeatherDetails.m
//  ECaddy
//
//  Created by RKing on 4/28/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "WeatherDetails.h"
#import <QuartzCore/QuartzCore.h>
#import "TBXML.h"
#import "ECaddyAppDelegate.h"

@implementation WeatherDetails

#define BORDER_WIDTH    3.0f

@synthesize courseObj;
@synthesize text;
@synthesize actIndicator;
@synthesize titleView;
@synthesize ywiView;
@synthesize currentView;
@synthesize todayView;
@synthesize tomView;
@synthesize curWind;
@synthesize curText;
@synthesize tempLbl;
@synthesize sunriseLbl;
@synthesize sunsetLbl;
@synthesize todayText;
@synthesize todayHigh;
@synthesize todayLow;
@synthesize tomText;
@synthesize tomHigh;
@synthesize tomLow;
@synthesize navBar;
@synthesize weatherPic;
@synthesize courseDetailsLbl;
@synthesize favstarBtn;
@synthesize errorView;
@synthesize yahooWeatherImg;
@synthesize windArrowImg;
@synthesize courseName;
@synthesize courseLoc;
@synthesize WOEID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization 
    }
    return self;
}

- (void)dealloc
{
//    [navBar release];
    [weatherPic release];
    [courseDetailsLbl release];
    [actIndicator release];
    [WOEID release];
    [favstarBtn release];
    [errorView release];
    [yahooWeatherImg release];
    [windArrowImg release];
    [tempLbl release];
    [curText release];
    [curWind release];
    [sunriseLbl release];
    [sunsetLbl release];
    [currentView release];
    [ywiView release];
    [titleView release];
    [todayText release];
    [todayHigh release];
    [todayLow release];
    [tomText release];
    [tomHigh release];
    [tomLow release];
    [todayView release];
    [tomView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.topItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];

    // Set the borders on the view groups
    self.currentView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.currentView.layer.borderWidth = BORDER_WIDTH;
    self.ywiView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.ywiView.layer.borderWidth = BORDER_WIDTH;
    self.titleView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.titleView.layer.borderWidth = BORDER_WIDTH;
    self.todayView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.todayView.layer.borderWidth = BORDER_WIDTH;
    self.tomView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.tomView.layer.borderWidth = BORDER_WIDTH;
    
    
    // Set the course details information 
   // NSString* courseLbl = [NSString stringWithFormat: @"%@\n%@", self.courseName, self.courseLoc];
    NSString* courseLbl = self.courseName;
    [self.courseDetailsLbl setText: courseLbl];
    //courseDetailsLbl.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    //courseDetailsLbl.layer.borderWidth = 2.0;
    
    // Set the initial state of the favorite star
    [self.favstarBtn setImage: [UIImage imageNamed: ([[self.courseObj favorite] boolValue] ? @"favstar_selected.png" : 
                                                     @"favstar_deselected.png")] forState: UIControlStateNormal];

}

- (void) viewWillAppear:(BOOL)animated
{  
    // Animate the activity indicator until the text is set
    [actIndicator setHidden: NO];
    [actIndicator startAnimating];
    
    //[self getWeatherInfo];
    //[self setWeatherInfo];
    
    // Do the weather processing in another thread
    [NSThread detachNewThreadSelector: @selector(getWeatherInfo) 
                             toTarget: self withObject:nil];
   
}

- (void)viewDidUnload
{
//    [self setNavBar:nil];
    [self setWeatherPic:nil];
    [self setCourseDetailsLbl:nil];
    [self setActIndicator:nil];
    [self setWOEID: nil];
    [self setFavstarBtn:nil];
    [self setErrorView:nil];
    [self setYahooWeatherImg:nil];
    [self setWindArrowImg:nil];
    [self setTempLbl:nil];
    [self setCurText:nil];
    [self setCurWind:nil];
    [self setSunriseLbl:nil];
    [self setSunsetLbl:nil];
    [self setCurrentView:nil];
    [self setYwiView:nil];
    [self setTitleView:nil];
    [self setTodayText:nil];
    [self setTodayHigh:nil];
    [self setTodayLow:nil];
    [self setTomText:nil];
    [self setTomHigh:nil];
    [self setTomLow:nil];
    [self setTodayView:nil];
    [self setTomView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (IBAction)favstarPressed:(id)sender {
    ECaddyAppDelegate* appDel = [ECaddyAppDelegate sharedAppDelegate];
    
    BOOL fav = [[self.courseObj favorite] boolValue];
    
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstar_selected.png" : 
                                                     @"favstar_deselected.png")] forState: UIControlStateNormal];
    
    [self.courseObj setFavorite: [NSNumber numberWithBool: fav]];
    
    [appDel saveContext];
}

- (void) cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Weather Methods

- (void) getWeatherInfo
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // Add the woeid to the URL
    NSURL* url2 = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@", self.WOEID]];
    NSString* str3 = [[NSString alloc] initWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
    
    [self setText:str3];
    
    [str3 release];
    
    [pool release];
    
    // Signal the main thread that we are done getting the weather
    [self performSelectorOnMainThread:@selector(setWeatherInfo) 
                           withObject: nil waitUntilDone:FALSE];
}

- (void) setWeatherInfo
{
    // If the weather text is nil then there was a problem with the network or something.
    if(!self.text){
        [self.actIndicator stopAnimating];
        [self.actIndicator setHidden: YES];
        
        [self.view bringSubviewToFront: self.errorView];
        [self.errorView setHidden: NO];
        
        return;
    }
    
    // Parse the XML to get the weather information
    TBXML* tbxml = [[TBXML tbxmlWithXMLString: self.text] retain];

    TBXMLElement* CHANNEL = [TBXML childElementNamed: @"channel" parentElement:tbxml.rootXMLElement];
    TBXMLElement* UNITS = [TBXML childElementNamed: @"yweather:units" parentElement: CHANNEL];
    TBXMLElement* WIND = [TBXML childElementNamed: @"yweather:wind" parentElement: CHANNEL];
    TBXMLElement* AST = [TBXML childElementNamed: @"yweather:astronomy" parentElement:CHANNEL];
    TBXMLElement* ITEM = [TBXML childElementNamed: @"item" parentElement: CHANNEL];
    TBXMLElement* COND = [TBXML childElementNamed: @"yweather:condition" parentElement:ITEM];
    TBXMLElement* DESC = [TBXML childElementNamed: @"description" parentElement:ITEM];
    TBXMLElement* TODAYFORECAST = [TBXML childElementNamed: @"yweather:forecast" parentElement:ITEM];
    TBXMLElement* TOMFORECAST = [TBXML nextSiblingNamed: @"yweather:forecast" searchFromElement:TODAYFORECAST];
    TBXMLElement* IMAGE = [TBXML childElementNamed: @"image" parentElement: CHANNEL];
    TBXMLElement* YWIURL = [TBXML childElementNamed: @"url" parentElement: IMAGE];
    
   
    NSString* desctext = [TBXML textForElement: DESC];
    NSString* imgsrcregex = @"http://[^\"]+";
    NSRange urlRange = [desctext rangeOfString: imgsrcregex options:NSRegularExpressionSearch];
    
    
    // Set the weather image in the UIImageView
    NSURL *url = [NSURL URLWithString: [desctext substringWithRange: urlRange]];
    NSData *data = [NSData dataWithContentsOfURL: url];
    UIImage *img = [[UIImage alloc] initWithData: data];
    [self.weatherPic setImage: img];
    [img release];
    img = nil;
    
    // Extract the other weaether info from the XML
    
    // Units for values
    NSString* tempUnits = [TBXML valueOfAttributeNamed: @"temperature" forElement: UNITS];
    //NSString* distanceUnits = [TBXML valueOfAttributeNamed: @"distance" forElement: UNITS];
    NSString* speedUnits = [TBXML valueOfAttributeNamed: @"speed" forElement: UNITS];
    
    // Wind information
    NSString* windChill = [TBXML valueOfAttributeNamed: @"chill" forElement: WIND];
    windChill = [windChill stringByAppendingString: tempUnits];
    NSString* windDir = [TBXML valueOfAttributeNamed: @"direction" forElement: WIND];
    NSString* windSpeed = [TBXML valueOfAttributeNamed: @"speed" forElement: WIND];
    windSpeed = [windSpeed stringByAppendingFormat: @" %@", [speedUnits uppercaseString]];
    
    // Astronomy information (sunrise/sunset)
    NSString* sunRise = [TBXML valueOfAttributeNamed: @"sunrise" forElement: AST];
    NSString* sunSet = [TBXML valueOfAttributeNamed: @"sunset" forElement: AST];
    
    // Current Condition Information
    NSString* curDesc = [TBXML valueOfAttributeNamed: @"text" forElement: COND];
    NSString* curTemp = [TBXML valueOfAttributeNamed: @"temp" forElement: COND];
    curTemp = [curTemp stringByAppendingFormat: @" %@", tempUnits];
    
    // Forecast information
    NSString* todayDesc = [TBXML valueOfAttributeNamed: @"text" forElement: TODAYFORECAST];
    NSString* todayL = [TBXML valueOfAttributeNamed: @"low" forElement: TODAYFORECAST];
    todayL = [todayL stringByAppendingString: tempUnits];
    NSString* todayH = [TBXML valueOfAttributeNamed: @"high" forElement: TODAYFORECAST];
    todayH = [todayH stringByAppendingString: tempUnits];
    //NSString* todayDay = [TBXML valueOfAttributeNamed: @"day" forElement: TODAYFORECAST];
    //NSString* todayDate = [TBXML valueOfAttributeNamed: @"date" forElement: TODAYFORECAST];
    
    
    NSString* tomDesc = [TBXML valueOfAttributeNamed: @"text" forElement: TOMFORECAST];
    NSString* tomL = [TBXML valueOfAttributeNamed: @"low" forElement: TOMFORECAST];
    tomL = [tomL stringByAppendingString: tempUnits];
    NSString* tomH = [TBXML valueOfAttributeNamed: @"high" forElement: TOMFORECAST];
    tomH = [tomH stringByAppendingString: tempUnits];
    //NSString* tomDay = [TBXML valueOfAttributeNamed: @"day" forElement: TOMFORECAST];
    //NSString* tomDate = [TBXML valueOfAttributeNamed: @"date" forElement: TOMFORECAST];
    
    // Release the XML Parser
    [tbxml release];
    tbxml = nil;
    
    // Set current weather information
    [self.tempLbl setText: [NSString stringWithFormat: @"Temp:\t%@", curTemp]];
    [self.curText setText: curDesc];
    [self.curWind setText: windSpeed];
    [self.sunriseLbl setText: [sunRise uppercaseString]];
    [self.sunsetLbl setText: [sunSet uppercaseString]];
    
    // Set today's forecast information
    // NSArray* splitterArr = [todayDate componentsSeparatedByString: @" "];
    // NSString* todayDateStr = [NSString stringWithFormat: @"%@, %@ %@", todayDay, 
    //                          [splitterArr objectAtIndex: 1], [splitterArr objectAtIndex: 0]];
    
    [self.todayText setText: todayDesc];
    [self.todayHigh setText: [NSString stringWithFormat: @"High: %@", todayH]];
    [self.todayLow setText: [NSString stringWithFormat: @"Low: %@", todayL]];
    
    // Set tomorrow's forecast information
    // splitterArr = [tomDate componentsSeparatedByString: @" "];
    // NSString* tomDateStr = [NSString stringWithFormat: @"%@, %@ %@", tomDay, 
    //                          [splitterArr objectAtIndex: 1], [splitterArr objectAtIndex: 0]];
    
    [self.tomText setText: tomDesc];
    [self.tomHigh setText: [NSString stringWithFormat: @"High: %@", tomH]];
    [self.tomLow setText: [NSString stringWithFormat: @"Low: %@", tomL]];
    
    // Set the wind arrow direction
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* windDirDegs = [f numberFromString: windDir];
    NSLog(@"Degrees: %@", windDirDegs);
    CGFloat rads = [windDirDegs floatValue] * 3.1416 / 180;
    windArrowImg.transform = CGAffineTransformMakeRotation(rads);
    [f release];
    
    // Set the Yahoo weather image
    NSURL * ywimgurl = [NSURL URLWithString: [TBXML textForElement: YWIURL]];
    NSData *ywimgdata = [NSData dataWithContentsOfURL: ywimgurl];
    UIImage *ywimg = [[UIImage alloc] initWithData: ywimgdata];
    [self.yahooWeatherImg setImage: ywimg];
    [ywimg release];
    ywimg = nil;
    
    // Stop the activity indicator
    [self.actIndicator stopAnimating];
    [self.actIndicator setHidden: YES];
}

@end
