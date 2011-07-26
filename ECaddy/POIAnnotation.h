//
//  POIAnnotation.h
//  ECaddy
//
//  Created by RKing on 5/3/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import<MapKit/MapKit.h>

@interface POIAnnotation : NSObject <MKAnnotation> {
    NSString* title;
    NSString* subtitle;
    
    UIImage* image;
    NSNumber* latitude;
    NSNumber* longitude;
    NSString* ThisNumber;
    
    BOOL draggable;
}

@property (retain, nonatomic) NSString* title;
@property (retain, nonatomic) NSString* subtitle;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

@property (nonatomic, assign, getter = isDraggable) BOOL draggable;

-(id) initWithLat:(double) initLat withLong:(double) initLongitude;

@end
