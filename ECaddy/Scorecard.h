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

@property (nonatomic, strong) NSNumber* active;
@property (nonatomic, strong) NSDate * dateplayed;
@property (nonatomic, strong) NSDictionary* scores;
@property (nonatomic, strong) NSString* playernames;
@property (nonatomic, strong) NSNumber* numplayers;
@property (nonatomic, strong) Course * course;

@end
