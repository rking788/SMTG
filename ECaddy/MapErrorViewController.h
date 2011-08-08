//
//  MapErrorViewController.h
//  SMTG
//
//  Created by Robert King on 8/7/11.
//  Copyright (c) 2011 University of Maine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapErrorViewController : UIViewController {
    UITextView *messageTV;
    UIButton *actionBtn;
    UINavigationItem *navBar;
    
    NSString* coursename;
    NSString* courselocation;
    NSString* err;
    
    id caller;
}

@property (retain, nonatomic) IBOutlet UINavigationItem *navBar;
@property (retain, nonatomic) IBOutlet UITextView *messageTV;
@property (retain, nonatomic) IBOutlet UIButton *actionBtn;

@property (retain, nonatomic) NSString* coursename;
@property (retain, nonatomic) NSString* courselocation;
@property (retain, nonatomic) NSString* err;

@property (retain, nonatomic) id caller;

- (IBAction) btnClicked:(id)sender;

- (void) noActiveCourse;
- (void) noCoordsAvailable;
- (void) doneBtnClicked;

@end
