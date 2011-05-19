//
//  CourseSelectViewController.h
//  ECaddy
//
//  Created by Teacher on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface CourseSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    NSMutableArray* courseNames;
    NSMutableArray* courseLocs;
    NSString* selectedState;
    NSManagedObjectContext* manObjCon;
}

@property (nonatomic, retain) NSMutableArray* courseNames;
@property (nonatomic, retain) NSMutableArray* courseLocs;
@property (nonatomic, retain) NSString* selectedState;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

- (void) fillNamesAndLocs;

@end
