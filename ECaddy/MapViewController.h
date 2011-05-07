//
//  MapViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "POIAnnotation.h"


@interface MapViewController : UIViewController <MKMapViewDelegate> {
    
    MKMapView *mapView;
    NSMutableArray* holeAnnotations;
    NSMutableArray* distanceAnnotations;
}

// Properties
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray* holeAnnotations;
@property (nonatomic, retain) NSMutableArray* distanceAnnotations;

// Methods
- (void)zoomToFitMapAnnotations:(MKMapView*)mapV;
- (void) holeAnnotsTeeLat:(double) lat1 teeLong:(double) long1 greenLat:(double) lat2 greenLong:(double) long2;


enum
{
    teeAnnotationIndex = 0,
    greenAnnotationIndex
};

@end
