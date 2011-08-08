//
//  MapViewController.h
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@class POIAnnotation;


@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    
    NSManagedObjectContext* manObjCon;
    
    MKMapView *mapView;
    UIButton *curLocationBtn;
   
    NSMutableArray* holeAnnotations;
    NSMutableArray* distanceAnnotations;
    
    NSUInteger curHole;
    
    BOOL coordsAvailable;
    
    NSArray* teeCoords;
    NSArray* greenCoords;
    
    MKPolyline* holeLine;
    MKPolylineView* holeLineView;
   
    UILabel *t2dLbl;
    UILabel *d2gLbl;

    CLLocationManager* locManager;
    CLLocation* userLoc;
    BOOL userLocEnabled;
    UIView *distanceContainer;
}

// Properties
@property (retain, nonatomic) IBOutlet UIView *distanceContainer;
@property (nonatomic, retain) IBOutlet UILabel *t2dLbl;
@property (retain, nonatomic) IBOutlet UILabel *d2gLbl;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UIButton *curLocationBtn;

@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

@property (nonatomic, retain) NSMutableArray* holeAnnotations;
@property (nonatomic, retain) NSMutableArray* distanceAnnotations;

@property (nonatomic, assign) NSUInteger curHole;

@property (nonatomic, assign, getter = isCoordsAvailable) BOOL coordsAvailable;

@property (nonatomic, retain) NSArray* teeCoords;
@property (nonatomic, retain) NSArray* greenCoords;

@property (nonatomic, retain) MKPolyline* holeLine;
@property (nonatomic, retain) MKPolylineView* holeLineView;

@property (nonatomic, retain) CLLocationManager* locManager;
@property (nonatomic, retain) CLLocation* userLoc;
@property (nonatomic, assign, getter = isUserLocEnabled) BOOL userLocEnabled;

// Methods
- (void)zoomToFitMapAnnotations:(MKMapView*)mapV;
- (void) holeAnnotsTeeCoords: (NSArray*) tee greenLat:(NSArray*) green;
- (void) clearHoleAnnotsAndArray: (BOOL) bClearArray;
- (void) clearDistanceAnnotsAndArray: (BOOL) bClearArray;

- (void) populateHoleCoords;

- (void) goToNextHole: (id) sender;
- (void) goToPrevHole: (id) sender;

- (void) drawMapLine;

+ (NSArray*) latAndLongForHole: (NSUInteger) hole FromCoords: (NSArray*) coords;

- (IBAction)toggleLocationOnOff:(id)sender;

- (void) startNewRound;

enum
{
    teeAnnotationIndex = 0,
    greenAnnotationIndex,
    userAnnotationIndex
};

@end
