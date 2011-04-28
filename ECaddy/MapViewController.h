//
//  MapViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate> {
    
    MKMapView *mapView;
}

// Properties
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

// Methods
- (void)zoomToFitMapAnnotations:(MKMapView*)mapV;

@end
