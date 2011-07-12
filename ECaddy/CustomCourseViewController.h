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
}
@property (nonatomic, retain) IBOutlet UITextField *courseNameTF;
@property (nonatomic, retain) IBOutlet UITextField *phoneTF;
@property (nonatomic, retain) IBOutlet UITextField *addressTF;
@property (nonatomic, retain) IBOutlet UITextField *cityTF;
@property (nonatomic, retain) IBOutlet UITextField *stateTF;
@property (nonatomic, retain) IBOutlet UITextField *countryTF;
@property (nonatomic, retain) IBOutlet UITextField *websiteTF;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

- (void) save;
- (void) cancel;

+ (BOOL) stateEnabled: (NSString*) state;
+ (NSString*) getWOEIDWithCity: (NSString*) city AndState: (NSString*) state;
+ (void) writeCourseToServer: (Course*) course;

@end
