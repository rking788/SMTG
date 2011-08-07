//
//  POIAnnotation.m
//  ECaddy
//
//  Created by RKing on 5/3/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "POIAnnotation.h"


@implementation POIAnnotation


@synthesize title;
@synthesize subtitle;
@synthesize image, latitude, longitude;
@synthesize draggable;

-(id) init{
    self = [super init];
    if(self){
        [self setLatitude: [NSNumber numberWithDouble: 44.902517]];
        [self setLongitude: [NSNumber numberWithDouble: -68.667400]];
        [self setTitle: @"Placeholder"];
        [self setDraggable: NO];
    }
    
    return self;
}

-(id) initWithLat:(double) initLat withLong:(double) initLongitude{
    self = [super init];
    if(self){
        [self setLatitude: [NSNumber numberWithDouble: initLat]];
        [self setLongitude: [NSNumber numberWithDouble: initLongitude]];
        [self setDraggable: NO];
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [[self latitude] doubleValue];
    theCoordinate.longitude = [[self longitude] doubleValue];
    return theCoordinate; 
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    [self setLatitude: [NSNumber numberWithDouble: newCoordinate.latitude]];
    [self setLongitude: [NSNumber numberWithDouble: newCoordinate.longitude]];
}

- (void)dealloc
{
    [title release];
    [subtitle release];
    [super dealloc];
}

- (NSString *)title
{
    return title;
}

// optional
- (NSString *)subtitle
{
    return subtitle;
}


@end
