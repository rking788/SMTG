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
    NSManagedObjectContext* manObjCon;
}
- (IBAction) startRoundClicked:(id)sender;
- (IBAction) favstarPressed: (id) sender;

@property (nonatomic, retain) IBOutlet UITextView *cdTV;
@property (nonatomic, retain) IBOutlet UIButton* favstarBtn;

@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

@property (nonatomic, retain) Course* courseObj;

- (void) populateCourseDetails;

@end
