//
//  CourseDetailViewController.h
//  SMTG
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
@property (nonatomic, strong) IBOutlet UITableView *tableV;
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UILabel *courseNameLbl;
@property (nonatomic, strong) IBOutlet UIButton* favstarBtn;
@property (nonatomic, strong) IBOutlet UIView *footView;

@property (nonatomic, strong) Course* courseObj;

@property (nonatomic, assign) NSInteger numSects;
@property (nonatomic, strong) NSString* addrStr;

@property (nonatomic, strong) NSManagedObjectContext* manObjCon;

- (IBAction) startRoundClicked:(id)sender;

@end
