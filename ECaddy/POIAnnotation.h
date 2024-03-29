//
//  POIAnnotation.h
//  SMTG
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
    
    BOOL draggable;
}

@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) NSString* subtitle;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, assign, getter = isDraggable) BOOL draggable;

-(id) initWithLat:(double) initLat withLong:(double) initLongitude;

@end
