//
//  MapViewController.m
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#pragma mark - TODOS: Need to figure out what to do if the player goes to the next hole while their current location is already active.
#pragma mark - TODO: Maybe use an instance property of curCourse, the app delegate curcourse object is accessed a few times

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "POIAnnotation.h"
#import "SMTGAppDelegate.h"
#import "Course.h"
#import "MapErrorViewController.h"

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
@synthesize curHole;
@synthesize coordsAvailable;
@synthesize teeCoords;
@synthesize greenCoords;
@synthesize holeLine;
@synthesize holeLineView;
@synthesize locManager;
@synthesize userLoc;
@synthesize userLocEnabled;
@synthesize adView;
@synthesize adVisible;

#pragma mark - View Lifecycle methods
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef LITE
    NSLog(@"Setting up the ad view because this is the free version");
    [self createAdBannerView];
#endif
    
    // Color the distance label container view
    //[self.distanceContainer setBackgroundColor: [UIColor colorWithRed: 0.870588243 green: 0.862745106 blue:0.0 alpha:1.0]];
    self.distanceContainer.layer.borderColor = [UIColor colorWithRed: 0.219607845 green: 0.521568656 blue:0 alpha:1.0].CGColor;
    self.distanceContainer.layer.borderWidth = 2.0;
    
    self.manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
    
    // Initialize the hole annotation size to 2 (tee and green)
    self.holeAnnotations = [[NSMutableArray alloc] initWithCapacity: 2];
    self.distanceAnnotations = [[NSMutableArray alloc] init];
    
    // TODO: This needs to be changed but it is the same basic idea.
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
}

- (void) viewWillAppear:(BOOL)animated
{
    
#ifdef LITE
    [self fixupAdView: self.interfaceOrientation];
#endif
    
    Course* curCourse = (Course*) [[SMTGAppDelegate sharedAppDelegate] curCourse];
    NSString* errStr = nil;

    if(!curCourse){
        errStr = @"NoActiveCourse";
    }
    
    if((!errStr) && (!self.coordsAvailable)){
        // Fill the coordinate arrays
        [self populateHoleCoords];
        
        // Start on hole 0 because gotonexthole will increment this value
        self.curHole = 0;
        [self goToNextHole: nil];
    }
    
    if(!errStr && !self.coordsAvailable){
        errStr = @"NoCoordsAvailable";
    }
    
    if(errStr){
        // Disable the next and previous buttons
        [self.navigationItem.leftBarButtonItem setEnabled: NO];
        [self.navigationItem.rightBarButtonItem setEnabled: NO];
        
        // Display the modal view controller
        MapErrorViewController* mevc = [[MapErrorViewController alloc] init];
        
        NSString* addr = [curCourse valueForKey: @"address"];
        NSString* state = [curCourse valueForKey: @"state"];
        NSString* country = [curCourse valueForKey: @"country"];
        
        [mevc setCaller: self];
        [mevc setErr: errStr];
        [mevc setCoursename: [curCourse coursename]];
        [mevc setCourselocation: [NSString stringWithFormat: @"%@ %@ %@", addr, state, country]];
        [mevc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
     
        [self presentModalViewController: mevc animated: YES];
        [mevc release];
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
    CLLocationCoordinate2D tee = [[self.holeAnnotations objectAtIndex: teeAnnotationIndex] coordinate];
    
    CLLocationCoordinate2D green = [[self.holeAnnotations objectAtIndex: greenAnnotationIndex] coordinate];
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    // Check if tee is minimum for any of these
    topLeftCoord.longitude = fmin(topLeftCoord.longitude, tee.longitude);
    topLeftCoord.latitude = fmax(topLeftCoord.latitude, tee.latitude);
    
    bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, tee.longitude);
    bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, tee.latitude);
    
    // Check if green is minimum for any of these
    topLeftCoord.longitude = fmin(topLeftCoord.longitude, green.longitude);
    topLeftCoord.latitude = fmax(topLeftCoord.latitude, green.latitude);
    
    bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, green.longitude);
    bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, green.latitude);
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
    
    region = [mapV regionThatFits:region];
    [mapV setRegion:region animated:YES];
}

- (void) goToNextHole:(id)sender
{
    // If we are past the last hole then display a summary view maybe
    if(self.curHole >= [self.teeCoords count])
        return;
    
    // Increment the current hole counter
    ++self.curHole;
    
    if(![self isCoordsAvailable])
        return;
    
    NSArray* tee = [MapViewController latAndLongForHole:self.curHole FromCoords: self.teeCoords];
    NSArray* green = [MapViewController latAndLongForHole:self.curHole FromCoords:self.greenCoords];
    [self holeAnnotsTeeCoords: tee greenLat:green]; 
    
    [self zoomToFitMapAnnotations:mapView];
    
    // Set the title to the current hole
    [self.navigationItem setTitle: [NSString stringWithFormat: @"Hole #%d", self.curHole]];
    
    if(self.curHole == 1){
        [self.navigationItem.leftBarButtonItem setEnabled: NO];
    }
    else if(self.curHole > 1){
        [self.navigationItem.leftBarButtonItem setEnabled: YES];
    }
}

- (void) goToPrevHole:(id)sender
{
    // If we are past the last hole then display a summary view maybe
    if(self.curHole == 1)
        return;
    
    // Increment the current hole counter
    --self.curHole;
    
    if(![self isCoordsAvailable])
        return;
    
    NSArray* tee = [MapViewController latAndLongForHole:self.curHole FromCoords: self.teeCoords];
    NSArray* green = [MapViewController latAndLongForHole:self.curHole FromCoords:self.greenCoords];
    [self holeAnnotsTeeCoords: tee greenLat:green]; 
    
    [self zoomToFitMapAnnotations:mapView];
    
    // Set the title to the current hole
    [self.navigationItem setTitle: [NSString stringWithFormat: @"Hole #%d", self.curHole]];
    
    if(self.curHole == 1){
        [self.navigationItem.leftBarButtonItem  setEnabled: NO];
    }
    else if(self.curHole > 1){
        [self.navigationItem.leftBarButtonItem setEnabled: YES];
    }
}

- (void) populateHoleCoords
{
    Course* curCourse = (Course*) [[SMTGAppDelegate sharedAppDelegate] curCourse];
    
    self.teeCoords = [curCourse valueForKey: @"teeCoords"];
    self.greenCoords = [curCourse valueForKey: @"greenCoords"];
    
    if(self.teeCoords && self.greenCoords)
        self.coordsAvailable = YES;
}

+ (NSArray*) latAndLongForHole: (NSUInteger) hole FromCoords: (NSArray*) coords
{
    NSNumberFormatter* numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setNumberStyle: NSNumberFormatterNoStyle];
    
    NSString* coordsStr = [coords objectAtIndex: (hole - 1)];
 
    NSNumber* lat = [numFormat numberFromString: [[coordsStr componentsSeparatedByString:@","] objectAtIndex: 0]];
    NSNumber* longitude = [numFormat numberFromString: [[coordsStr componentsSeparatedByString: @","] objectAtIndex: 1]];
    
    [numFormat release];
    
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
        
        // Only do this if coordinates are available
        if(self.coordsAvailable){
            [self.mapView addAnnotation: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]];
            [self drawMapLine];
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

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(!self.userLoc){
        self.userLoc = [[CLLocation alloc] initWithLatitude: newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        
        // set the center of the map to the user location
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.02 / 10; // zoom level
        span.longitudeDelta=0.02 / 10;
        
        region.span=span;
        region.center = self.userLoc.coordinate;
        
        [mapView setRegion:region animated:TRUE];
        [mapView regionThatFits:region];
    }
    
    if(![self isUserLocEnabled]){
        
        if([self isCoordsAvailable]){
            // Remove the tee annotation and show the user annotation
            [self.mapView removeAnnotation: [self.holeAnnotations objectAtIndex: teeAnnotationIndex]];
        
            // Draw line from user location -> draggable -> green
            [self drawMapLine];
        }
    }
}

- (void) drawMapLine
{
    NSNumber* midLat = [(POIAnnotation*) [self.distanceAnnotations objectAtIndex: 0] latitude];
    NSNumber* midLong = [(POIAnnotation*) [self.distanceAnnotations objectAtIndex: 0] longitude];
    
    // Remove the old line
    [self.mapView removeOverlay: self.holeLine];
    [self setHoleLineView: nil]; 
    
    //  Create the line from the tee to the green or from the user location to the green
    double lat1; 
    double long1;
    if([self isUserLocEnabled]){
        lat1 = self.userLoc.coordinate.latitude;
        long1 = self.userLoc.coordinate.longitude;
    }
    else{
        lat1 = [[[self.holeAnnotations objectAtIndex: teeAnnotationIndex] latitude] doubleValue];
        long1 = [[[self.holeAnnotations objectAtIndex: teeAnnotationIndex] longitude] doubleValue];
    }
    
    double lat2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] latitude] doubleValue];
    double long2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] longitude] doubleValue];
    
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * 3);
    
    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude: lat1 longitude:long1];
    pointArray[0] = MKMapPointForCoordinate([loc1 coordinate]);
    
    CLLocation* midloc = [[CLLocation alloc] initWithLatitude: [midLat doubleValue] longitude: [midLong doubleValue]];
    pointArray[1] = MKMapPointForCoordinate([midloc coordinate]);
    
    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude: lat2 longitude:long2];
    pointArray[2] = MKMapPointForCoordinate([loc2 coordinate]);
    
    [self setHoleLine: [MKPolyline polylineWithPoints: pointArray count: 3]];
    
    [self.mapView addOverlay: [self holeLine]];
    
    // Find the distance between the two points
    CLLocationDistance distanceToGreen = [loc2 distanceFromLocation: midloc] * 1.0936133;
    CLLocationDistance distanceToPin = [midloc distanceFromLocation: loc1] * 1.0935133;
    CLLocationDistance distanceOverall = [loc2 distanceFromLocation: loc1] * 1.0935133;
    
    // Set the distance label
    [self.t2dLbl setText: [NSString stringWithFormat: @"%d yd", (int)distanceToPin]];
    [self.d2gLbl setText: [NSString stringWithFormat: @"%d yd", (int)distanceToGreen]];
    
    // Set the title for the annotation equal to the distance to that annotation from the tee
    [[self.distanceAnnotations objectAtIndex:0] setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceToPin]];
    [[self.holeAnnotations objectAtIndex: greenAnnotationIndex] setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceOverall]];
    
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
    
    if(([self.holeAnnotations objectAtIndex:teeAnnotationIndex]) && ([self.holeAnnotations objectAtIndex: greenAnnotationIndex])){
        [self.mapView removeAnnotations: self.holeAnnotations];
    }
    
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
    double lat1 = [[tee objectAtIndex: 0] doubleValue] / 1000000.0;
    double long1 = [[tee objectAtIndex: 1] doubleValue] / 1000000.0;
    
    double lat2 = [[green objectAtIndex: 0] doubleValue] / 1000000.0;
    double long2 = [[green objectAtIndex: 1] doubleValue] / 1000000.0;
    
    // Clear the annotations if they already exist
    [self clearHoleAnnotsAndArray: YES];
    [self clearDistanceAnnotsAndArray: YES];
    
    POIAnnotation* teeAnnot = [[POIAnnotation alloc] initWithLat:lat1 withLong:long1];
    
    POIAnnotation* greenAnnot = [[POIAnnotation alloc] initWithLat:lat2 withLong:long2];
    
    POIAnnotation* draggable1 = [[POIAnnotation alloc] initWithLat: ((lat1+lat2)/2) withLong:((long1+long2)/2)];
    [draggable1 setDraggable: YES];
    
    [self.holeAnnotations insertObject:teeAnnot atIndex: teeAnnotationIndex];
    [self.holeAnnotations insertObject:greenAnnot atIndex: greenAnnotationIndex];
    [self.distanceAnnotations addObject:draggable1];

    [self.mapView addAnnotations:self.holeAnnotations];
    [self.mapView addAnnotations: self.distanceAnnotations];

    //  Create the line from the tee to the green
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * 3);
    
    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude: lat1 longitude:long1];
    pointArray[0] = MKMapPointForCoordinate([loc1 coordinate]);
    
    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude: lat2 longitude:long2];
    pointArray[1] = MKMapPointForCoordinate([loc2 coordinate]);
    
    CLLocation* midloc = [[CLLocation alloc] initWithLatitude:((lat1+lat2)/2) longitude:((long1+long2)/2)];
    pointArray[2] = MKMapPointForCoordinate([midloc coordinate]);
    
    [self setHoleLine: [MKPolyline polylineWithPoints: pointArray count: 3]];
    [self.mapView addOverlay: self.holeLine];

    free((void*) pointArray);
    
    // Find the distance between the two points
    CLLocationDistance distanceToGreen = [loc2 distanceFromLocation: midloc] * 1.0936133;
    CLLocationDistance distanceToPin = [midloc distanceFromLocation: loc1] * 1.0935133;
    CLLocationDistance distanceOverall = [loc2 distanceFromLocation: loc1] * 1.0935133;
    
    // Set the distance label
    [self.t2dLbl setText: [NSString stringWithFormat: @"%d yd", (int)distanceToPin]];
    [self.d2gLbl setText: [NSString stringWithFormat:@" %d yd", (int) distanceToGreen]];

    // Set the title for the annotation equal to the distance to that annotation from the tee
    [draggable1 setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceToPin]];
    [greenAnnot setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceOverall]];
        
    [teeAnnot release];
    [greenAnnot release];
    [draggable1 release];
    
    [loc1 release];
    [loc2 release];
    [midloc release];
    
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

# pragma mark - TODO CRITICAL replace a lot of this code with [self drawMapLine]
# pragma mark - TODO The annotation distances are not being recalculated after the draggable annotation is moved

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateEnding){
        POIAnnotation* annot = annotationView.annotation;
        
        [self.mapView removeOverlay: self.holeLine];
        [self setHoleLineView: nil]; 
        
        //  Create the line from the tee to the green
        double lat1;
        double long1;
        
        if([self isUserLocEnabled]){
            lat1 = self.userLoc.coordinate.latitude;
            long1 = self.userLoc.coordinate.longitude;
        }
        else{
            lat1 = [[[self.holeAnnotations objectAtIndex: teeAnnotationIndex] latitude] doubleValue];
            long1 = [[[self.holeAnnotations objectAtIndex:teeAnnotationIndex] longitude] doubleValue];
        }
        double lat2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] latitude] doubleValue];
        double long2 = [[[self.holeAnnotations objectAtIndex: greenAnnotationIndex] longitude] doubleValue];
        
        MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * 3);
        
        CLLocation* loc1 = [[CLLocation alloc] initWithLatitude: lat1 longitude:long1];
        pointArray[0] = MKMapPointForCoordinate([loc1 coordinate]);
        
        CLLocation* midloc = [[CLLocation alloc] initWithLatitude: [annot.latitude doubleValue] longitude: [annot.longitude doubleValue]];
        pointArray[1] = MKMapPointForCoordinate([midloc coordinate]);
        
        CLLocation* loc2 = [[CLLocation alloc] initWithLatitude: lat2 longitude:long2];
        pointArray[2] = MKMapPointForCoordinate([loc2 coordinate]);
        
        // Recalculate the distance from the tee to the distance annotation
        // Find the distance between the two points
        CLLocationDistance distanceToGreen = [loc2 distanceFromLocation: midloc] * 1.0936133;
        CLLocationDistance distanceToPin = [midloc distanceFromLocation: loc1] * 1.0935133;
        CLLocationDistance distanceOverall = [loc2 distanceFromLocation: loc1] * 1.0935133;
        
        // Set the distance label
        [self.t2dLbl setText: [NSString stringWithFormat: @"%d yd", (int)distanceToPin]];
        [self.d2gLbl setText: [NSString stringWithFormat: @"%d yd", (int)distanceToGreen]];
        
        // Set the title for the annotation equal to the distance to that annotation from the tee
        [annot setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceToPin]];
        [(POIAnnotation*) [self.holeAnnotations objectAtIndex: greenAnnotationIndex] setTitle: [NSString stringWithFormat: @"%d yd", (int) distanceOverall]];
        
        
        [self setHoleLine: [MKPolyline polylineWithPoints: pointArray count: 3]];
        [self.mapView addOverlay: [self holeLine]];
        
        // Free up memory
        free((void*) pointArray);
        [loc1 release];
        [loc2 release];
        [midloc release];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    //NSLog(@"Done");
    // TODO: This doesn't work very well. It is not called reliably
    
    // Select the green annotation to display the yardage bubble
   // [self.mapView selectAnnotation: [self.holeAnnotations objectAtIndex:greenAnnotationIndex]animated: YES];
}

- (void) startNewRound
{
    Course* curCourse = (Course*) [[SMTGAppDelegate sharedAppDelegate] curCourse];
    [self.tabBarController setSelectedViewController: [self.tabBarController.viewControllers objectAtIndex: 0]];
    UINavigationController* navCont = (UINavigationController*) self.tabBarController.selectedViewController;
    [[[navCont viewControllers] objectAtIndex: 0] setCourseObj: curCourse];
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
