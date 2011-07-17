//
//  CourseDetailViewController.h
//  ECaddy
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Course;

@interface CourseDetailViewController : UIViewController {
    
    UITextView *cdTV;
    Course* courseObj;
    NSManagedObjectContext* manObjCon;
}
@property (nonatomic, retain) IBOutlet UITextView *cdTV;
@property (nonatomic, retain) IBOutlet UIButton* favstarBtn;

@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

@property (nonatomic, retain) Course* courseObj;

- (IBAction) startRoundClicked:(id)sender;
- (IBAction) favstarPressed: (id) sender;

- (void) populateCourseDetails;

@end
