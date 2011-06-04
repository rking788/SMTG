//
//  Scorecard.h
//  ECaddy
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Scorecard : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * dateplayed;
@property (nonatomic, retain) id scores;
@property (nonatomic, retain) Course * course;

@end
