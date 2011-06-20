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

@synthesize courseObj;
@synthesize text;
@synthesize actIndicator;
@synthesize curWeatherTV;
@synthesize todayForecastTV;
@synthesize nextDayForecastTV;
@synthesize navBar;
@synthesize weatherPic;
@synthesize courseDetailsLbl;
@synthesize favstarBtn;
@synthesize errorView;
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
    [curWeatherTV release];
//    [navBar release];
    [weatherPic release];
    [courseDetailsLbl release];
    [todayForecastTV release];
    [nextDayForecastTV release];
    [actIndicator release];
    [WOEID release];
    [favstarBtn release];
    [errorView release];
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

    // Set the course details information 
    NSString* courseLbl = [NSString stringWithFormat: @"%@\n%@", self.courseName, self.courseLoc];
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
    [self setCurWeatherTV: nil];
//    [self setNavBar:nil];
    [self setWeatherPic:nil];
    [self setCourseDetailsLbl:nil];
    [self setTodayForecastTV:nil];
    [self setNextDayForecastTV:nil];
    [self setActIndicator:nil];
    [self setWOEID: nil];
    [self setFavstarBtn:nil];
    [self setErrorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    // This is the woeid value for old town, me
    NSURL* url2 = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@", [self WOEID]]];
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
        [self.view bringSubviewToFront: self.errorView];
        [self.errorView setHidden: NO];
        return;
    }
    
    // Parse the XML to get the weather information 
    // TODO: Maybe this should use a struct or something? or a class i have no idea right now
    // just want it to work.
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
    windSpeed = [windSpeed stringByAppendingString: speedUnits];
    
    // Astronomy information (sunrise/sunset)
    NSString* sunRise = [TBXML valueOfAttributeNamed: @"sunrise" forElement: AST];
    NSString* sunSet = [TBXML valueOfAttributeNamed: @"sunset" forElement: AST];
    
    // Current Condition Information
    NSString* curText = [TBXML valueOfAttributeNamed: @"text" forElement: COND];
    NSString* curTemp = [TBXML valueOfAttributeNamed: @"temp" forElement: COND];
    curTemp = [curTemp stringByAppendingString: tempUnits];
    
    // Forecast information
    NSString* todayText = [TBXML valueOfAttributeNamed: @"text" forElement: TODAYFORECAST];
    NSString* todayLow = [TBXML valueOfAttributeNamed: @"low" forElement: TODAYFORECAST];
    todayLow = [todayLow stringByAppendingString: tempUnits];
    NSString* todayHigh = [TBXML valueOfAttributeNamed: @"high" forElement: TODAYFORECAST];
    todayHigh = [todayHigh stringByAppendingString: tempUnits];
    NSString* todayDay = [TBXML valueOfAttributeNamed: @"day" forElement: TODAYFORECAST];
    NSString* todayDate = [TBXML valueOfAttributeNamed: @"date" forElement: TODAYFORECAST];
    
    
    NSString* tomText = [TBXML valueOfAttributeNamed: @"text" forElement: TOMFORECAST];
    NSString* tomLow = [TBXML valueOfAttributeNamed: @"low" forElement: TOMFORECAST];
    tomLow = [tomLow stringByAppendingString: tempUnits];
    NSString* tomHigh = [TBXML valueOfAttributeNamed: @"high" forElement: TOMFORECAST];
    tomHigh = [tomHigh stringByAppendingString: tempUnits];
    NSString* tomDay = [TBXML valueOfAttributeNamed: @"day" forElement: TOMFORECAST];
    NSString* tomDate = [TBXML valueOfAttributeNamed: @"date" forElement: TOMFORECAST];
    
    // Release the XML Parser
    [tbxml release];
    tbxml = nil;
    
    // Set current weather information
    NSString* currentWeatherStr = [NSString stringWithFormat: 
                                   @"%@\t%@\nWind: %@\t%@\nSunrise:\t%@\tSunset:\t%@",
                                   curText, curTemp, windDir, windSpeed, sunRise, sunSet];
    [self.curWeatherTV setText: currentWeatherStr];
    
    // Set today's forecast information
    NSArray* splitterArr = [todayDate componentsSeparatedByString: @" "];
    NSString* todayDateStr = [NSString stringWithFormat: @"%@, %@ %@", todayDay, 
                              [splitterArr objectAtIndex: 1], [splitterArr objectAtIndex: 0]];
    NSString* todayForecast = [NSString stringWithFormat: @"%@\n%@\nHigh: %@\t\tLow: %@",
                               todayDateStr, todayText, todayHigh, todayLow];
    [self.todayForecastTV setText: todayForecast];
    
    // Set tomorrow's forecast information
    splitterArr = [tomDate componentsSeparatedByString: @" "];
    NSString* tomDateStr = [NSString stringWithFormat: @"%@, %@ %@", tomDay, 
                              [splitterArr objectAtIndex: 1], [splitterArr objectAtIndex: 0]];
    NSString* tomForecast = [NSString stringWithFormat: @"%@\n%@\nHigh: %@\t\tLow: %@",
                               tomDateStr, tomText, tomHigh, tomLow];
    [self.nextDayForecastTV setText: tomForecast];
    
    [actIndicator stopAnimating];
    [actIndicator setHidden: YES];
}

@end
