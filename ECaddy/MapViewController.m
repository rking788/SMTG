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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [mapView release];
    [super dealloc];
}

- (void)zoomToFitMapAnnotations:(MKMapView*)mapV
{
    CLLocationCoordinate2D tee;
    tee.latitude = 44.044435;
    tee.longitude = -69.939185;
    
    CLLocationCoordinate2D green;
    green.latitude = 44.044311;
    green.longitude = -69.937617;
    
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

@end
