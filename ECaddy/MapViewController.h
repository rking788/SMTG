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
#import "iAd/ADBannerView.h"
#import "MapErrorViewController.h"

@class POIAnnotation;
@class Course;


@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, ADBannerViewDelegate, StartNewRoundDelegate> {
    
    NSManagedObjectContext* manObjCon;
    
    MKMapView *mapView;
    UIButton *curLocationBtn;
    UIView *contentView;
   
    NSMutableArray* holeAnnotations;
    NSMutableArray* distanceAnnotations;
    
    Course* curCourse;
    NSUInteger curHole;
    
    BOOL coordsAvailable;
    
    // Coordinates to/from CoreData
    NSArray* teeCoords;
    NSArray* greenCoords;
    
    // Temporary coordinates array used when logging coordinates
    NSMutableArray* tempTeeCoords;
    NSMutableArray* tempGreenCoords;
    
    MKPolyline* holeLine;
    MKPolylineView* holeLineView;
   
    UILabel *t2dLbl;
    UILabel *d2gLbl;

    CLLocationManager* locManager;
    CLLocation* userLoc;
    BOOL userLocEnabled;
    UIView *distanceContainer;
    
    id adView;
    BOOL adVisible;
}

// Properties
@property (strong, nonatomic) IBOutlet UIView *distanceContainer;
@property (nonatomic, strong) IBOutlet UILabel *t2dLbl;
@property (strong, nonatomic) IBOutlet UILabel *d2gLbl;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *curLocationBtn;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) NSManagedObjectContext* manObjCon;

@property (nonatomic, strong) NSMutableArray* holeAnnotations;
@property (nonatomic, strong) NSMutableArray* distanceAnnotations;

@property (nonatomic, strong) Course* curCourse;
@property (nonatomic, assign) NSUInteger curHole;

@property (nonatomic, assign, getter = isCoordsAvailable) BOOL coordsAvailable;

@property (nonatomic, strong) NSArray* teeCoords;
@property (nonatomic, strong) NSArray* greenCoords;

@property (nonatomic, strong) NSMutableArray* tempTeeCoords;
@property (nonatomic, strong) NSMutableArray* tempGreenCoords;

@property (nonatomic, strong) MKPolyline* holeLine;
@property (nonatomic, strong) MKPolylineView* holeLineView;

@property (nonatomic, strong) CLLocationManager* locManager;
@property (nonatomic, strong) CLLocation* userLoc;
@property (nonatomic, assign, getter = isUserLocEnabled) BOOL userLocEnabled;

@property (nonatomic, strong) id adView;
@property (nonatomic) BOOL adVisible;

// Methods
- (void)zoomToFitMapAnnotations:(MKMapView*)mapV;
- (void) holeAnnotsTeeCoords: (NSArray*) tee greenLat:(NSArray*) green;
- (void) clearHoleAnnotsAndArray: (BOOL) bClearArray;
- (void) clearDistanceAnnotsAndArray: (BOOL) bClearArray;

- (void) populateHoleCoords;

- (void) goToNextHole: (id) sender;
- (void) goToPrevHole: (id) sender;
- (void) goToHole: (NSUInteger) holeNum;

- (void) drawMapLine;

+ (NSArray*) latAndLongForHole: (NSUInteger) hole FromCoords: (NSArray*) coords;

- (IBAction)toggleLocationOnOff:(id)sender;
- (IBAction)logTeeCoords:(id)sender;
- (IBAction)logGreenCoords:(id)sender;

- (void) startNewRound;

#ifdef LITE
- (void)createAdBannerView;
- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;
#endif

enum
{
    teeAnnotationIndex = 0,
    greenAnnotationIndex,
    userAnnotationIndex
};

@end
