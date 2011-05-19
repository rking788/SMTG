//
//  DirectoryViewController.h
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface DirectoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
 
    NSSet* stateSet;
    NSSet* countrySet;
    NSDictionary* abbrsDict;
    NSDictionary* stateArrDict;
    NSManagedObjectContext* manObjCon;
    UINavigationController *navController;
}
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@property (nonatomic, retain) NSSet* stateSet;
@property (nonatomic, retain) NSSet* countrySet;
@property (nonatomic, retain) NSDictionary* abbrsDict;
@property (nonatomic, retain) NSDictionary* stateArrDict;
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;

- (void) fillStatesCountries;

@end
