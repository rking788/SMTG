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
    MKPolyline* holeLine;
    MKPolylineView* holeLineView;
    UILabel *distLbl;
}

// Properties
// Possibly temporary overlays for distances
@property (nonatomic, retain) IBOutlet UILabel *distLbl;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) NSMutableArray* holeAnnotations;
@property (nonatomic, retain) NSMutableArray* distanceAnnotations;
@property (nonatomic, retain) MKPolyline* holeLine;
@property (nonatomic, retain) MKPolylineView* holeLineView;

// Methods
- (void)zoomToFitMapAnnotations:(MKMapView*)mapV;
- (void) holeAnnotsTeeLat:(double) lat1 teeLong:(double) long1 greenLat:(double) lat2 greenLong:(double) long2;
- (void) clearHoleAnnotsAndArray: (BOOL) bClearArray;

enum
{
    teeAnnotationIndex = 0,
    greenAnnotationIndex
};

@end
