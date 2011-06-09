//
//  ScoreTrackerViewController.h
//  ECaddy
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scorecard.h"
#import "Course.h"


@interface ScoreTrackerViewController : UIViewController {
    Scorecard* scorecard;
    UITextView *headerTextView;
}
@property (nonatomic, retain) IBOutlet UITextView *headerTextView;
@property (nonatomic, retain) Scorecard* scorecard;

@end
