//
//  MapErrorViewController.h
//  SMTG
//
//  Created by Robert King on 8/7/11.
//  Copyright (c) 2011 University of Maine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartNewRoundDelegate <NSObject>

- (void) startNewRound;

@end

@interface MapErrorViewController : UIViewController {
    UITextView *messageTV;
    UIButton *actionBtn;
    UINavigationItem *navBar;
    
    NSString* coursename;
    NSString* courselocation;
    NSString* err;
    
    id<StartNewRoundDelegate> caller;
}

@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (strong, nonatomic) IBOutlet UITextView *messageTV;
@property (strong, nonatomic) IBOutlet UIButton *actionBtn;

@property (strong, nonatomic) NSString* coursename;
@property (strong, nonatomic) NSString* courselocation;
@property (strong, nonatomic) NSString* err;

@property (strong, nonatomic) id<StartNewRoundDelegate> caller;

- (IBAction) btnClicked:(id)sender;

- (void) noActiveCourse;
- (void) noCoordsAvailable;
- (void) doneBtnClicked;

@end
