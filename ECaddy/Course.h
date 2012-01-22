//
//  Course.h
//  SMTG
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Course : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSArray* womenpars;
@property (nonatomic, strong) NSString * woeid;
@property (nonatomic, strong) NSNumber * numholes;
@property (nonatomic, strong) NSString * coursename;
@property (nonatomic, strong) NSArray* menpars;
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSNumber* pending;
@property (nonatomic, strong) NSSet* scorecards;
@property (nonatomic, strong) NSArray* greenCoords;
@property (nonatomic, strong) NSArray* teeCoords;

@end
