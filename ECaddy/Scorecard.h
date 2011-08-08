//
//  Scorecard.h
//  SMTG
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;


@interface Scorecard : NSManagedObject{
@private
}

@property (nonatomic, retain) NSNumber* active;
@property (nonatomic, retain) NSDate * dateplayed;
@property (nonatomic, retain) NSMutableDictionary* scores;
@property (nonatomic, retain) NSString* playernames;
@property (nonatomic, retain) NSNumber* numplayers;
@property (nonatomic, retain) Course * course;

@end
