//
//  Course.h
//  ECaddy
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Course : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSArray* womenpars;
@property (nonatomic, retain) NSString * woeid;
@property (nonatomic, retain) NSNumber * numholes;
@property (nonatomic, retain) NSString * coursename;
@property (nonatomic, retain) NSArray* menpars;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSSet* scorecards;

@end
