//
//  dbinit.h
//  SMTG
//
//  Created by Teacher on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface dbinit : NSObject {
    
}

@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

- (void) insertWOEIDS;
- (void) fillDB;

@end
