//
//  MapViewController.m
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "POIAnnotation.h"
#import "SMTGAppDelegate.h"
#import "Course.h"
#import "MapErrorViewController.h"


#pragma mark - TODO CRITICAL Finish implementing and testing the coordinate logging features. Do we need all of these synthesized properties? "Analyze" the project and remove all memory leaks and other problems.
@implementation MapViewController

@synthesize manObjCon;
@synthesize distanceContainer;
@synthesize t2dLbl;
@synthesize d2gLbl;
@synthesize mapView;
@synthesize curLocationBtn;
@synthesize contentView;
@synthesize holeAnnotations;
@synthesize distanceAnnotations;
@synthesize curCourse;
@synthesize curHole;
@synthesize coordsAvailable;
@synthesize teeCoords, greenCoords;
@synthesize tempTeeCoords, tempGreenCoords;
@synthesize holeLine;
@synthesize holeLineView;
@synthesize locManager;
@synthesize userLoc;
@synthesize userLocEnabled;
@synthesize adView;
@synthesize adVisible;

#define SCREEN_WIDTH    320.0
#define SCREEN_HEIGHT   480.0
#define T_LOGBTN_TAG    66
#define G_LOGBTN_TAG    67
#define T_ACTIND_TAG    76
#define G_ACTIND_TAG    77

#pragma mark - View Lifecycle methods
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef LITE
    [self createAdBannerView];
#endif
    
    // Color the distance label container view
    self.distanceContainer.layer.borderColor = [UIColor colorWithRed: 0.219607845 green: 0.521568656 blue:0 alpha:1.0].CGColor;
    self.distanceContainer.layer.borderWidth = 2.0;
    
    self.manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
    
    // Initialize the hole annotation size to 2 (tee and green)
    self.holeAnnotations = [[NSMutableArray alloc] initWithCapacity: 2];
    self.distanceAnnotations = [[NSMutableArray alloc] init];
    
    
    
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"                                            
        style:UIBarButtonItemStyleBordered 
        target:self 
        action: @selector(goToNextHole:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    // Add a button to the left side of the navigation bar for the prev hole button
    UIBarButtonItem* prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous"                                             
                                        style:UIBarButtonItemStylePlain 
                                        target:self 
                                        action: @selector(goToPrevHole:)];
    self.navigationItem.leftBarButtonItem = prevButton;
    
    self.curHole = 1;
}

- (void) viewWillAppear:(BOOL)animated
{
    
#ifdef LITE
    [self fixupAdView: self.interfaceOrientation];
#endif

    NSString* errStr = nil;
    Course* tempCourse = (Course*) [[SMTGAppDelegate sharedAppDelegate] curCourse];
    if(!self.curCourse)
        self.curCourse = tempCourse;
    else if(![tempCourse.coursename isEqualToString: self.curCourse.coursename]){
        // If the course has changed then we need to move to the 
        // first hole on this new course so clear the previous coordiantes and 
        // other information
        self.curCourse = tempCourse;
        
        self.coordsAvailable = NO;
        [self.teeCoords release];
        self.teeCoords = nil;
        [self.greenCoords release];
        self.greenCoords = nil;
    }
    
    if(!self.curCourse){
        errStr = @"NoActiveCourse";
    }
    
    if((!errStr) && (!self.coordsAvailable)){
        // Fill the coordinate arrays
        [self populateHoleCoords];
        
        [self goToHole: 1];
    }
    
    if(!errStr && !self.coordsAvailable){
        errStr = @"NoCoordsAvailable";
    }
    
    if(errStr){
        // Display the modal view controller
        MapErrorViewController* mevc = [[MapErrorViewController alloc] init];
        
        NSString* addr = [self.curCourse valueForKey: @"address"];
        NSString* state = [self.curCourse valueForKey: @"state"];
        NSString* country = [self.curCourse valueForKey: @"country"];
        
        [mevc setCaller: self];
        [mevc setErr: errStr];
        [mevc setCoursename: [self.curCourse coursename]];
        [mevc setCourselocation: [NSString stringWithFormat: @"%@ %@ %@", addr, state, country]];
        [mevc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
     
        [self presentModalViewController: mevc animated: YES];
        [mevc release];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    BOOL shouldSave = NO;
    
    if(self.tempTeeCoords){
        self.curCourse.teeCoords = self.tempTeeCoords;
        self.curCourse.pending = [NSNumber numberWithBool: YES];
        shouldSave = YES;
    }
    
    if(self.tempGreenCoords){
        self.curCourse.greenCoords = self.tempGreenCoords;
        self.curCourse.pending = [NSNumber numberWithBool: YES];
        shouldSave = YES;
    }
    
    // If we should save the managed object context then do it !
    if(shouldSave){
        [self.manObjCon save: nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL ret = NO;
    
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        ret = YES;
    }
    else if(interfaceOrientation == UIInterfaceOrientationPortrait){
        ret = YES;
    }
    
#ifdef LITE
    [self fixupAdView: interfaceOrientation];
#endif
    
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        [self.distanceContainer viewWithTag: 30].center = CGPointMake( (SCREEN_HEIGHT / 2), self.distanceContainer.center.y);
    else
        [self.distanceContainer viewWithTag: 30].center = CGPointMake( (SCREEN_WIDTH / 2), self.distanceContainer.center.y);
    
    //return ret;
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setManObjCon: nil];
    [self setMapView:nil];
    [self setHoleAnnotations: nil];
    [self setDistanceAnnotations:nil];
    [self setTeeCoords: nil];
    [self setGreenCoords: nil];
    [self setTempTeeCoords: nil];
    [self setTempGreenCoords: nil];
    [self setT2dLbl:nil];
    [self setLocManager: nil];
    [self setUserLoc: nil];
    [self setDistanceContainer:nil];
    [self setD2gLbl:nil];
    [self setCurLocationBtn:nil];
    [self setContentView:nil];
    [self setAdView: nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [mapView release];
    [holeAnnotations release];
    [distanceAnnotations release];
    [t2dLbl release];
    [teeCoords release];
    [greenCoords release];
    [tempTeeCoords release];
    [tempGreenCoords release];
    [manObjCon release];
    [locManager release];
    [userLoc release];
    [distanceContainer release];
    [d2gLbl release];
    [curLocationBtn release];
    [contentView release];
    [adView release];
    [super dealloc];
}

- (void)zoomToFitMapAnnotations:(MKMapView*)mapV
{
    CLLocationCoordinate2D tee, green;
    BOOL isValidTee = NO, isValidGreen = NO;
    
    if (!self.userLocEnabled && (teeAnnotationIndex < [self.holeAnnotations count])) {
        tee = [[self.holeAnnotations objectAtIndex: teeAnnotationIndex] coordinate];
        isValidTee = YES;
    }
    else if(self.userLocEnabled){
        tee = self.userLoc.coordinate;
        isValidTee = YES;
    }
    
    if(greenAnnotationIndex < [self.holeAnnotations count]){
        green = [[self.holeAnnotations objectAtIndex: greenAnnotationIndex] coordinate];
        isValidGreen = YES;
    }
        
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    if(isValidTee){
        // Check if tee is minimum for any of these
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, tee.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, tee.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, tee.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, tee.latitude);
    }
    
    if(isValidGreen){
        // Check if green is minimum for any of these
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, green.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, green.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, green.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, green.latitude);
    }
    
    if((!isValidTee) && (!isValidGreen))
        return;
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
    
    region = [mapV regionThatFits: region];
    [mapV setRegion:region animated: YES];
}

- (void) goToNextHole:(id)sender
{
    // If we are past the last hole then display a summary view maybe
    if(self.curHole >= [self.curCourse.numholes unsignedIntValue])
        return;
 
    // Increment the current hole counter
    ++self.curHole;
    
 //   if(![self isCoordsAvailable])
 //       return;
    
    [self goToHole: self.curHole];
}

- (void) goToPrevHole:(id)sender
{
    
    // If we are past the last hole then display a summary view maybe
    if(self.curHole == 1)
        return;
    
    // Increment the current hole counter
    --self.curHole;
    
 //   if(![self isCoordsAvailable])
 //       return;
    
    [self goToHole: self.curHole];
}

- (void) goToHole: (NSUInteger) holeNum
{
    NSArray* tee = nil;
    NSArray* green = nil;
    
    if(holeNum <= [self.teeCoords count]){
        tee = [MapViewController latAndLongForHole: holeNum FromCoords: self.teeCoords];
    }
    
    if(holeNum <= [self.greenCoords count]){
        green = [MapViewController latAndLongForHole: holeNum FromCoords:self.greenCoords];
    }
    
    [self holeAnnotsTeeCoords: tee greenLat: green]; 
    
    if((tee != nil) || (green != nil))
        [self zoomToFitMapAnnotations: mapView];
    
    // Disable the tee or green buttons if they are already available
    UIButton* teeBtn = (UIButton*) [self.view viewWithTag: T_LOGBTN_TAG];
    UIButton* greenBtn = (UIButton*) [self.view viewWithTag: G_LOGBTN_TAG];
    
    if(tee != nil){
        [teeBtn setHidden: YES];
    }
    else{
        [teeBtn setImage: [UIImage imageNamed: @"golftee_mapbtn.png"] forState: UIControlStateNormal];
        [teeBtn setHidden: NO];
    }
    if(green != nil){
        [greenBtn setHidden: YES];
    }
    else{
        [greenBtn setImage: [UIImage imageNamed: @"green_mapbtn.png"] forState: UIControlStateNormal];
        [greenBtn setHidden: NO];
    }
    
    // Set the title to the current hole
    [self.navigationItem setTitle: [NSString stringWithFormat: @"Hole #%d", holeNum]];
    
    if(holeNum == 1){
        [self.navigationItem.leftBarButtonItem  setEnabled: NO];
    }
    else if(holeNum > 1){
        [self.navigationItem.leftBarButtonItem setEnabled: YES];
    }
    
    if(holeNum == [self.curCourse.numholes unsignedIntegerValue])
        [self.navigationItem.rightBarButtonItem setEnabled: NO];
    else
        [self.navigationItem.rightBarButtonItem setEnabled: YES];
}

- (void) populateHoleCoords
{
    self.teeCoords = [self.curCourse valueForKey: @"teeCoords"];
    self.greenCoords = [self.curCourse valueForKey: @"greenCoords"];
    
    if(self.teeCoords && self.greenCoords)
        self.coordsAvailable = YES;

}

+ (NSArray*) latAndLongForHole: (NSUInteger) hole FromCoords: (NSArray*) coords
{
    NSNumberFormatter* numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setNumberStyle: NSNumberFormatterNoStyle];
    
    NSString* coordsStr = [coords objectAtIndex: (hole - 1)];

    if([coordsStr isEqualToString: @""])
        return nil;
 
    NSNumber* lat = [numFormat numberFromString: [[coordsStr componentsSeparatedByString:@","] objectAtIndex: 0]];
    NSNumber* longitude = [numFormat numberFromString: [[coordsStr componentsSeparatedByString: @","] objectAtIndex: 1]];
    
    [numFormat release];
    
    if((!lat) || (!longitude))
        return nil;
    
    return [NSArray arrayWithObjects:lat, longitude, nil];
}

- (IBAction)toggleLocationOnOff:(id)sender
{
    if(!self.locManager){
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
    }
    
    if([self isUserLocEnabled]){
        // User location is disabled so add the tee back on and redraw the line
        [self.curLocationBtn setImage: [UIImage imageNamed: @"curlocbtn.png"] forState: UIControlStateNormal];
        
        [self.locManager stopUpdatingLocation];
        [self.mapView setShowsUserLocation: NO];
        self.userLocEnabled = NO;
        [self.userLoc release];
        self.userLoc = nil;
        
        // Only do this if coordinates are available
        if(self.coordsAvailable){
            if(teeAnnotationIndex < [self.holeAnnotations count])
                [self.mapView addAnnotation: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]];
            [self drawMapLine];
            [self zoomToFitMapAnnotations: mapView];
        }
    }
    else{
        if([CLLocationManager locationServicesEnabled]){
            // User location is enabled
            [self.curLocationBtn setImage: [UIImage imageNamed: @"curlocbtn-enabled.png"] forState: UIControlStateNormal];
            
            [self.locManager startUpdatingLocation];
            
            self.userLocEnabled = YES;
            [self.mapView setShowsUserLocation: YES];
        }     
    }
}

- (IBAction)logTeeCoords:(id)sender
{
    if (![self isUserLocEnabled]){
        NSString* mesg = @"Please enable your current location with the button in the bottom right corner before logging coordinates";
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Enable Location" message: mesg delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
        [av show];
        [av release];
        return;
    }
    
    // Should set this background to the empty background of the button
    // Without the tee or green icons inside of it
    UIButton* teeBtn = (UIButton*) [self.view viewWithTag: T_LOGBTN_TAG];
    [teeBtn setImage: [UIImage imageNamed: @"blank_mapbtn.png"] forState: UIControlStateNormal];
    
    UIActivityIndicatorView* actInd = (UIActivityIndicatorView*)[self.view viewWithTag: T_ACTIND_TAG];
    [actInd startAnimating];
    
    if(!self.tempTeeCoords){
        if(self.curCourse.teeCoords){
            self.tempTeeCoords = [self.curCourse.teeCoords mutableCopy];
        }
        else{
        self.tempTeeCoords = [[NSMutableArray alloc] init];
        for(int i = 0; i < [self.curCourse.numholes intValue] ; ++i)
            [self.tempTeeCoords addObject: @""];
        }
    }
    
    if(!self.userLoc){
        //Set error image in the log coordinates button
        NSLog(@"Error logging coordinates");
        
        [actInd stopAnimating];
        [teeBtn setImage: [UIImage imageNamed: @"failure_mapbtn.png"] forState: UIControlStateNormal];
        
        return;
    }
    
    CLLocationDegrees lat = self.userLoc.coordinate.latitude;
    CLLocationDegrees lng = self.userLoc.coordinate.longitude;
    NSString* coordStr = [NSString stringWithFormat: @"%d,%d", (int)(lat*1000000), (int)(lng*1000000)];
    
    [self.tempTeeCoords replaceObjectAtIndex: (self.curHole - 1) withObject: coordStr];
    
    self.teeCoords = self.tempTeeCoords;
    self.curCourse.teeCoords = self.tempTeeCoords;
    self.curCourse.pending = [NSNumber numberWithBool: YES];
    
    [actInd stopAnimating];
    
    [teeBtn setImage: [UIImage imageNamed: @"success_mapbtn.png"] forState: UIControlStateNormal];
}

- (IBAction)logGreenCoords:(id)sender
{
    if (![self isUserLocEnabled]){
        NSString* mesg = @"Please enable your current location with the button in the bottom right corner before logging coordinates";
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Enable Location" message: mesg delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
        [av show];
        [av release];
        return;
    }

    // Should set this background to the empty background of the button
    // Without the tee or green icons inside of it
    UIButton* greenBtn = (UIButton*) [self.view viewWithTag: G_LOGBTN_TAG];
    [greenBtn setImage: [UIImage imageNamed: @"blank_mapbtn.png"] forState: UIControlStateNormal];
    
    UIActivityIndicatorView* actInd = (UIActivityIndicatorView*)[self.view viewWithTag: G_ACTIND_TAG];
    [actInd startAnimating];
    
    if(!self.tempGreenCoords){
        if(self.curCourse.greenCoords){
            self.tempGreenCoords = [self.curCourse.greenCoords mutableCopy];
        }
        else{
            self.tempGreenCoords = [[NSMutableArray alloc] init];
            for(int i = 0; i < [self.curCourse.numholes intValue] ; ++i)
                [self.tempGreenCoords addObject: @""];
        }
    }
    
    if(!self.userLoc){
        //Set error image in the log coordinates button
        [actInd stopAnimating];
        [greenBtn setImage: [UIImage imageNamed: @"failure_mapbtn.png"] forState: UIControlStateNormal];
        
        return;
    }
    
    CLLocationDegrees lat = self.userLoc.coordinate.latitude;
    CLLocationDegrees lng = self.userLoc.coordinate.longitude;
    NSString* coordStr = [NSString stringWithFormat: @"%d,%d", (int)(lat*1000000), (int)(lng*1000000)];
    
    [self.tempGreenCoords replaceObjectAtIndex: (self.curHole - 1) withObject: coordStr];
    
    self.greenCoords = self.tempGreenCoords;
    self.curCourse.greenCoords = self.tempGreenCoords;
    self.curCourse.pending = [NSNumber numberWithBool: YES];
    
    [actInd stopAnimating];
    
    [greenBtn setImage: [UIImage imageNamed: @"success_mapbtn.png"] forState: UIControlStateNormal];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    BOOL shouldDrawLine = NO;
    
    if(!self.userLoc){
        self.userLoc = [[CLLocation alloc] initWithLatitude: newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
        if(![self isCoordsAvailable]){
            // No coords available so just center the map
            // on the user's location
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta=0.02 / 10; // zoom level
            span.longitudeDelta=0.02 / 10;
        
            region.span=span;
            region.center = self.userLoc.coordinate;
        
            [mapView setRegion:region animated:TRUE];
            [mapView regionThatFits:region];
        }
        else{
            // If coordinates are available then we want to zoom
            // in on all three points not just the user
            [self zoomToFitMapAnnotations: mapView];
        }
        
        shouldDrawLine = YES;
    }
    
    // The person hasn't moved so don't bother drawing the line again it will make
    // it flash if we do
    if(!((newLocation.coordinate.latitude == oldLocation.coordinate.latitude)
         && (newLocation.coordinate.longitude == oldLocation.coordinate.longitude))){
        shouldDrawLine = YES;
    }
        
    if([self isUserLocEnabled]){
        
        if([self isCoordsAvailable]){
            // Remove the tee annotation and show the user annotation;
            if(teeAnnotationIndex < [self.holeAnnotations count]){
                [self.mapView removeAnnotation: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]];
            }
            
            if(shouldDrawLine){
                // Draw line from user location -> draggable -> green
                [self drawMapLine];
            }
        }
    }
}

- (void) drawMapLine
{
    // Remove the old line
    [self.mapView removeOverlay: self.holeLine];
    [self setHoleLineView: nil]; 
    
    NSNumber* midLat = nil;
    NSNumber* midLong = nil;
    
    //  Create the line from the tee to the green or from the user location to the green
    double lat1, long1; 
    double lat2, long2;
    CLLocation* loc1 = nil;
    CLLocation* midloc = nil;
    CLLocation* loc2 = nil;
    int validLocs = 0;
    
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * 3);
    
    if([self isUserLocEnabled]){
        lat1 = self.userLoc.coordinate.latitude;
        long1 = self.userLoc.coordinate.longitude;

        loc1 = [[CLLocation alloc] initWithLatitude: lat1 longitude:long1];
        pointArray[validLocs] = MKMapPointForCoordinate([loc1 coordinate]);
        ++validLocs;
    }
    else{
        if(teeAnnotationIndex < [self.holeAnnotations count]){
            lat1 = [[[self.holeAnnotations objectAtIndex: teeAnnotationIndex] latitude] doubleValue];
            long1 = [[[self.holeAnnotations objectAtIndex: teeAnnotationIndex] longitude] doubleValue];
            
            loc1 = [[CLLocation alloc] initWithLatitude: lat1 longitude:long1];
            pointArray[validLocs] = MKMapPointForCoordinate([loc1 coordinate]);
            ++validLocs;
        }
    }
 
    if([self.distanceAnnotations count] != 0){
        midLat = [(POIAnnotation*) [self.distanceAnnotations objectAtIndex: 0] latitude];
        midLong = [(POIAnnotation*) [self.distanceAnnotations objectAtIndex: 0] longitude];
        
        midloc = [[CLLocation alloc] initWithLatitude: [midLat doubleValue] longitude: [midLong doubleValue]];
        pointArray[validLocs] = MKMapPointForCoordinate([midloc coordinate]);
        ++validLocs;
    }
    
    if(greenAnnotationIndex < [self.holeAnnotations count]){
        lat2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] latitude] doubleValue];
        long2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] longitude] doubleValue];
        
        loc2 = [[CLLocation alloc] initWithLatitude: lat2 longitude:long2];
        pointArray[validLocs] = MKMapPointForCoordinate([loc2 coordinate]);
        ++validLocs;
    }
    
    if(validLocs == 0)
        return;
    
    [self setHoleLine: [MKPolyline polylineWithPoints: pointArray count: validLocs]];
    
    [self.mapView addOverlay: [self holeLine]];
    
    // Find the distance between the two points
    CLLocationDistance multiplier = 1.0;
    NSString* distanceUnits = [[NSUserDefaults standardUserDefaults] objectForKey: @"distanceunits"];
    NSString* unitsStr = @"m";
    
    // If the default distance units are yards then we need a multiplier in the 
    // distance calculation, the return from the distance function is meters
    if([distanceUnits isEqualToString: @"Yards"]){
        multiplier = 1.0936133;
        unitsStr = @"yd";
    }
    
    if((loc1 != nil) && (midloc != nil)){
        CLLocationDistance distanceToPin = [midloc distanceFromLocation: loc1] * multiplier;
        [self.t2dLbl setText: [NSString stringWithFormat: @"%d %@", (int)distanceToPin, unitsStr]];
        
        [[self.distanceAnnotations objectAtIndex:0] setTitle: [NSString stringWithFormat: @"%d %@", (int) distanceToPin, unitsStr]];
    }
    
    if((loc2 != nil) && (midloc != nil)){
        CLLocationDistance distanceToGreen = [loc2 distanceFromLocation: midloc] * multiplier;
        CLLocationDistance distanceOverall = [loc2 distanceFromLocation: loc1] * multiplier;
        
        [self.d2gLbl setText: [NSString stringWithFormat: @"%d %@", (int)distanceToGreen, unitsStr]];
        
        [[self.holeAnnotations objectAtIndex: greenAnnotationIndex] setTitle: [NSString stringWithFormat: @"%d %@", (int) distanceOverall, unitsStr]];
    }
    
    // Free up memory
    free((void*) pointArray);
    [loc1 release];
    [loc2 release];
    [midloc release];
}

#pragma mark Map View Methods

- (void) clearHoleAnnotsAndArray: (BOOL) bClearArray
{
    if([[self.mapView annotations] count] == 0)
        return;
    if([self.holeAnnotations count] == 0)
        return;
    
    if(teeAnnotationIndex < [self.holeAnnotations count])
        [self.mapView removeAnnotation: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]];
    if(greenAnnotationIndex < [self.holeAnnotations count])
        [self.mapView removeAnnotation: [self.holeAnnotations objectAtIndex: greenAnnotationIndex]];
    
    // If the bool flag is set then remove the annotations from the array too
    if(bClearArray)
        [self.holeAnnotations removeAllObjects];
}

- (void) clearDistanceAnnotsAndArray: (BOOL) bClearArray
{
    if([[self.mapView annotations] count] == 0)
        return;
    if([self.distanceAnnotations count] == 0)
        return;
    
    if(self.holeLine)
        [self.mapView removeOverlay: self.holeLine];
        [self setHoleLineView: nil]; 

    [self.mapView removeAnnotations: self.distanceAnnotations];
    
    // If the bool flag is set then remove the annotations from the array too
    if(bClearArray)
        [self.distanceAnnotations removeAllObjects];
}


- (void) holeAnnotsTeeCoords:(NSArray *)tee greenLat:(NSArray *)green
{
    double lat1, long1; 
    double lat2, long2;
    BOOL isTeeValid = NO, isGreenValid = NO;
    
    // Clear the annotations if they already exist
    [self clearHoleAnnotsAndArray: YES];
    [self clearDistanceAnnotsAndArray: YES];
    
    if([tee count] != 0){
        // Add the tee annotation if coordinates are available
        lat1 = [[tee objectAtIndex: 0] doubleValue] / 1000000.0;
        long1 = [[tee objectAtIndex: 1] doubleValue] / 1000000.0;
        POIAnnotation* teeAnnot = [[POIAnnotation alloc] initWithLat:lat1 withLong:long1];
        [self.holeAnnotations insertObject:teeAnnot atIndex: teeAnnotationIndex];
        
        isTeeValid = YES;
    }
    
    if([green count] != 0){
        // Add the green annotation if coordinates are available
        lat2 = [[green objectAtIndex: 0] doubleValue] / 1000000.0;
        long2 = [[green objectAtIndex: 1] doubleValue] / 1000000.0;
        POIAnnotation* greenAnnot = [[POIAnnotation alloc] initWithLat:lat2 withLong:long2];
        [self.holeAnnotations insertObject:greenAnnot atIndex: greenAnnotationIndex];
    
        isGreenValid = YES;
    }
    
    if(isTeeValid && isGreenValid){
        POIAnnotation* draggable1 = [[POIAnnotation alloc] initWithLat: ((lat1+lat2)/2) withLong:((long1+long2)/2)];
        [draggable1 setDraggable: YES];
        [self.distanceAnnotations addObject:draggable1];
    }
    else if(isTeeValid){
        POIAnnotation* draggable1 = [[POIAnnotation alloc] initWithLat: lat1 withLong: long1];
        [draggable1 setDraggable: YES];
        [self.distanceAnnotations addObject:draggable1];
    }
    else if(isGreenValid){
        POIAnnotation* draggable1 = [[POIAnnotation alloc] initWithLat: lat2 withLong: long2];
        [draggable1 setDraggable: YES];
        [self.distanceAnnotations addObject:draggable1];
    }
    
    [self.mapView addAnnotations: self.holeAnnotations];
    [self.mapView addAnnotations: self.distanceAnnotations];

    [self drawMapLine];
    
    return;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
    MKOverlayView* overlayView = nil;
    
    if(overlay == self.holeLine){
        //if we have not yet created an overlay view for this overlay, create it now.
        if(nil == self.holeLineView){
            self.holeLineView = [[[MKPolylineView alloc] initWithPolyline:self.holeLine] autorelease];
            self.holeLineView.fillColor = [UIColor yellowColor];
            self.holeLineView.strokeColor = [UIColor yellowColor];
            self.holeLineView.lineWidth = 2;
            self.holeLineView.alpha = 0.3;
        }
        
        overlayView = self.holeLineView;
        
    }
    
    return overlayView;
    
}

// MapView animation method for custom annotations
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    MKAnnotationView *aV; 
    for (aV in views) {
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our two custom annotations
    if ([annotation isKindOfClass:[POIAnnotation class]] && [(POIAnnotation*)annotation isDraggable]){
        // try to dequeue an existing pin view first
        static NSString* POIDraggableAnnotationID = @"poiAnnotationIdentifierDraggable";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:POIDraggableAnnotationID];
        if (!pinView)
        {
            MKAnnotationView* customPinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: POIDraggableAnnotationID] autorelease];
            
            [customPinView setCanShowCallout: YES];
            [customPinView setDraggable: YES];
            [customPinView setImage: [UIImage imageNamed: @"mapdraggable.png"]];
            //[customPinView setPinColor: MKPinAnnotationColorPurple];
            
            return customPinView;
        }
        return pinView;
    }
    if ([annotation isKindOfClass:[POIAnnotation class]] && (![(POIAnnotation*) annotation isDraggable])){
        
        // try to dequeue an existing pin view first
        static NSString* POIAnnotationID = @"poiAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:POIAnnotationID];
        if (!pinView){
            // if an existing pin view was not available, create one
            //MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
            //                                       initWithAnnotation:annotation reuseIdentifier:POIAnnotationID] autorelease];
            //customPinView.pinColor = MKPinAnnotationColorPurple;
            //customPinView.animatesDrop = NO;
            //customPinView.canShowCallout = NO;
            //customPinView.draggable = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            //UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[rightButton addTarget:self
            //                action:@selector(showDetails:)
            //      forControlEvents:UIControlEventTouchUpInside];
            //customPinView.rightCalloutAccessoryView = rightButton;
            
            MKAnnotationView* customPinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: POIAnnotationID] autorelease];
            
            // TODO: Use this offset to offset the callout so it doesn't adjust
            // the map when the bubble is displayed this value will need to be diferent
            // if the green is on the left (x will have to be +20)
            CGPoint calloutpoint = [customPinView calloutOffset];
            calloutpoint.x -= 10;
            
            [customPinView setCalloutOffset: calloutpoint];
            [customPinView setCanShowCallout: YES];
            
            // TODO: Probably remove this offset once new images are used
            [customPinView setCenterOffset: CGPointMake(0, -16)];
            
            if([customPinView.annotation isEqual: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]]){
                [customPinView setImage: [UIImage imageNamed: @"golftee.png"]];
            }
            else if([customPinView.annotation isEqual: [self.holeAnnotations objectAtIndex:greenAnnotationIndex]]){
                [customPinView setImage: [UIImage imageNamed: @"greenflag.png"]];
            }
            
            return customPinView;
        }
        else{
            pinView.annotation = annotation;
        }
        
        if([pinView.annotation isEqual: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]]){
            [pinView setImage: [UIImage imageNamed: @"golftee.png"]];
        }
        else if([pinView.annotation isEqual: [self.holeAnnotations objectAtIndex:greenAnnotationIndex]]){
            [pinView setImage: [UIImage imageNamed: @"greenflag.png"]];
        }
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateEnding){
        
        [self.mapView removeOverlay: self.holeLine];
        [self setHoleLineView: nil]; 
        
        [self drawMapLine];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    // TODO: This doesn't work very well. It is not called reliably
    
    // Select the green annotation to display the yardage bubble
   // [self.mapView selectAnnotation: [self.holeAnnotations objectAtIndex:greenAnnotationIndex]animated: YES];
}

- (void) startNewRound
{
    [self.tabBarController setSelectedViewController: [self.tabBarController.viewControllers objectAtIndex: 0]];
    UINavigationController* navCont = (UINavigationController*) self.tabBarController.selectedViewController;
    [[[navCont viewControllers] objectAtIndex: 0] setValue:self.curCourse forKey: @"courseObj"];
    [navCont popToRootViewControllerAnimated: NO];
    [[[navCont viewControllers] objectAtIndex: 0] viewDidAppear: YES];
}

#pragma mark - iAd methods
#ifdef LITE
- (int)getBannerHeight:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight: self.interfaceOrientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adView = [[[classAdBannerView alloc] 
                        initWithFrame:CGRectZero] autorelease];
        [adView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
                                                   ADBannerContentSizeIdentifierPortrait, 
                                                   ADBannerContentSizeIdentifierLandscape, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];            
        }
        [adView setFrame:CGRectOffset([adView frame], 0, -[self getBannerHeight])];
        [adView setDelegate:self];
        
        [self.view addSubview:adView];        
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (adView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (adVisible) {
            CGRect adBannerViewFrame = [adView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 0;
            [adView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 
            [self getBannerHeight:toInterfaceOrientation];
            contentViewFrame.size.height = self.view.frame.size.height - 
            [self getBannerHeight:toInterfaceOrientation];
            contentView.frame = contentViewFrame;
        } else {
            CGRect adBannerViewFrame = [adView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
            [adView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            contentView.frame = contentViewFrame;            
        }
        [UIView commitAnimations];
    }   
}

#pragma mark ADBannerViewDelegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"A Banner was loaded");
    
    if (!adVisible){                
        adVisible = YES;
        [self fixupAdView: self.interfaceOrientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to load a banner");
    
    if (adVisible){        
        adVisible = NO;
        [self fixupAdView: self.interfaceOrientation];
    }
}
#endif


@end
