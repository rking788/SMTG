//
//  CourseDetailViewController.h
//  ECaddy
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Course.h"

@interface CourseDetailViewController : UIViewController {
    
    UITextView *cdTV;
    Course* courseObj;
}
@property (nonatomic, retain) IBOutlet UITextView *cdTV;

@property (nonatomic, retain) NSManagedObject* courseObj;

- (void) populateCourseDetails;

@end
