//
//  CourseDetailViewController.h
//  ECaddy
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

enum
{
    kADDR_SECT = 0,
    kPHONE_SECT,
    kWEBSITE_SECT
};

@class Course;

@interface CourseDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    
    UITableView *tableV;
    UIView *titleView;
    UILabel *courseNameLbl;
    UIButton* favstarBtn;
    UIView *footView;
    
    Course* courseObj;
    
    NSInteger numSects;
    NSString* addrStr;
    
    NSManagedObjectContext* manObjCon;
}
@property (nonatomic, retain) IBOutlet UITableView *tableV;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UILabel *courseNameLbl;
@property (nonatomic, retain) IBOutlet UIButton* favstarBtn;
@property (nonatomic, retain) IBOutlet UIView *footView;

@property (nonatomic, retain) Course* courseObj;

@property (nonatomic, assign) NSInteger numSects;
@property (nonatomic, retain) NSString* addrStr;

@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

- (IBAction) startRoundClicked:(id)sender;
- (IBAction) mapBtnPressed:(id)sender;
- (IBAction) favstarPressed: (id) sender;

- (void) populateCourseDetails;

@end
