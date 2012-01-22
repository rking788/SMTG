//
//  CustomCourseViewController.h
//  SMTG
//
//  Created by RKing on 7/5/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Course;

@interface CustomCourseViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    UITextField* activeField;
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
    UIScrollView *scrollView;
}
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITextField* activeField;
@property (nonatomic, strong) IBOutlet UITextField *courseNameTF;
@property (nonatomic, strong) IBOutlet UITextField *phoneTF;
@property (nonatomic, strong) IBOutlet UITextField *numHolesTF;
@property (nonatomic, strong) IBOutlet UITextField *addressTF;
@property (nonatomic, strong) IBOutlet UITextField *cityTF;
@property (nonatomic, strong) IBOutlet UITextField *stateTF;
@property (nonatomic, strong) IBOutlet UITextField *countryTF;
@property (nonatomic, strong) IBOutlet UITextField *websiteTF;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *uploadSeg;
@property (nonatomic, strong) IBOutlet UIView *uploadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uploadingInd;

- (void) save;
- (void) cancel;
- (void) writeCourseToServer: (Course*) course;
- (void) dismiss: (NSNumber*) shouldSave;

- (void)registerForKeyboardNotifications;

+ (BOOL) stateEnabled: (NSString*) state;
+ (NSString*) getWOEIDWithCity: (NSString*) city AndState: (NSString*) state;

@end
