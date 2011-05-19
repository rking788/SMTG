//
//  MapViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

@synthesize mapView;
@synthesize holeAnnotations;
@synthesize distanceAnnotations;
@synthesize holeLine;
@synthesize holeLineView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the hole annotation size to 2 (tee and green)
    self.holeAnnotations = [[NSMutableArray alloc] initWithCapacity: 2];
    self.distanceAnnotations = [[NSMutableArray alloc] init];
    
    [self holeAnnotsTeeLat:44.044435 teeLong:-69.939185 greenLat:44.044311 greenLong:-69.937617];
    
    // TODO: Remove This. Set the region of the map to the first hole
    [self zoomToFitMapAnnotations:mapView];
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
    
    return ret;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setHoleAnnotations: nil];
    [self setDistanceAnnotations:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [mapView release];
    [holeAnnotations release];
    [distanceAnnotations release];
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
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapV regionThatFits:region];
    [mapV setRegion:region animated:YES];
}

#pragma mark Map View Methods

- (void) clearHoleAnnotsAndArray: (BOOL) bClearArray
{
    if(self.holeAnnotations == nil)
        return;
    
    // TODO: Not sure if this check is correct for the case where no objects have been added yet
    // or if there is an easier way of doing it.
    if(([self.holeAnnotations objectAtIndex:teeAnnotationIndex] != nil) && ([self.holeAnnotations objectAtIndex: greenAnnotationIndex])){
        [self.mapView removeAnnotations: self.holeAnnotations];
    }
    
    // If the bool flag is set then remove the annotations from the array too
    if(bClearArray)
        [self.holeAnnotations removeAllObjects];
}

- (void) holeAnnotsTeeLat:(double) lat1 teeLong:(double) long1 greenLat:(double) lat2 greenLong:(double) long2
{    
    // Clear the annotations if they already exist
    [self.holeAnnotations removeAllObjects];
    
    POIAnnotation* teeAnnot = [[POIAnnotation alloc] initWithLat:lat1 withLong:long1];
    [teeAnnot setImage: [UIImage imageNamed: @"tee.png"]];
    
    POIAnnotation* greenAnnot = [[POIAnnotation alloc] initWithLat:lat2 withLong:long2];
    [greenAnnot setImage: [UIImage imageNamed: @"green.png"]];
    
    [self.holeAnnotations insertObject:teeAnnot atIndex: teeAnnotationIndex];
    [self.holeAnnotations insertObject:greenAnnot atIndex: greenAnnotationIndex];

    [self.mapView addAnnotations:self.holeAnnotations];
    
    [teeAnnot release];
    [greenAnnot release];
    
    //  Create the line from the tee to the green
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * 2);
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat1, long1);
    pointArray[0] = MKMapPointForCoordinate(coord);
    
    coord = CLLocationCoordinate2DMake(lat2, long2);
    pointArray[1] = MKMapPointForCoordinate(coord);
    
    self.holeLine = [MKPolyline polylineWithPoints: pointArray count: 2];
    [self.mapView addOverlay: holeLine];
    
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
    //
    if ([annotation isKindOfClass:[POIAnnotation class]]) // for Golden Gate Bridge
    {
        // try to dequeue an existing pin view first
        static NSString* POIAnnotationID = @"poiAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:POIAnnotationID];
        if (!pinView)
        {
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
            
            [customPinView setCanShowCallout: NO];
            [customPinView setCenterOffset: CGPointMake(0, -20)];
            // NSLog(@"Draggable: %@", ([customPinView isDraggable] ? @"YES" : @"NO"));
            
             [customPinView setImage: [((POIAnnotation*)annotation) image]];
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
   /* NSLog(@"Changing Drag State");
    if(newState == MKAnnotationViewDragStateEnding){
        POIAnnotation* annot = annotationView.annotation;
        NSNumber* num1 = annot.latitude;
        NSNumber* num2 = annot.longitude;
        NSLog(@"New Lat: %@, New Long: %@", num1, num2);
    }
    else if(newState == MKAnnotationViewDragStateStarting){
        POIAnnotation* annot = annotationView.annotation;
        NSNumber* num1 = annot.latitude;
        NSNumber* num2 = annot.longitude;
        NSLog(@"Starting Lat: %@, Starting Long: %@", num1, num2);
    }*/
}


@end
