//
//  CustomCourseViewController.h
//  ECaddy
//
//  Created by RKing on 7/5/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Course;

@interface CustomCourseViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    UITextField *courseNameTF;
    UITextField *phoneTF;
    UITextField *addressTF;
    UITextField *cityTF;
    UITextField *stateTF;
    UITextField *countryTF;
    UITextField *websiteTF;
    UINavigationBar *navBar;
    UISegmentedControl *uploadSeg;
    UIView *uploadingView;
    UIActivityIndicatorView *uploadingInd;
    UITextField *numHolesTF;
}
@property (nonatomic, retain) IBOutlet UITextField *courseNameTF;
@property (nonatomic, retain) IBOutlet UITextField *phoneTF;
@property (nonatomic, retain) IBOutlet UITextField *numHolesTF;
@property (nonatomic, retain) IBOutlet UITextField *addressTF;
@property (nonatomic, retain) IBOutlet UITextField *cityTF;
@property (nonatomic, retain) IBOutlet UITextField *stateTF;
@property (nonatomic, retain) IBOutlet UITextField *countryTF;
@property (nonatomic, retain) IBOutlet UITextField *websiteTF;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *uploadSeg;
@property (nonatomic, retain) IBOutlet UIView *uploadingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *uploadingInd;

- (void) save;
- (void) cancel;
- (void) writeCourseToServer: (Course*) course;
- (void) dismiss: (NSNumber*) shouldSave;

+ (BOOL) stateEnabled: (NSString*) state;
+ (NSString*) getWOEIDWithCity: (NSString*) city AndState: (NSString*) state;

@end
