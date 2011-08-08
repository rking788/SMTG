//
//  ScorecardTableViewController.h
//  SMTG
//
//  Created by RKing on 6/28/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObjectContext;
@class Scorecard;

@interface ScorecardTableViewController : UITableViewController {
    NSManagedObjectContext* manObjCon;
    
    NSMutableDictionary* courseNameDict;
    
    BOOL actives;
    Scorecard* actScorecard;
    Scorecard* selScorecard;
}
@property (nonatomic, retain) NSManagedObjectContext* manObjCon;
@property (nonatomic, retain) NSMutableDictionary* courseNameDict;

@property (nonatomic, assign, getter = isActives) BOOL actives;
@property (nonatomic, retain) Scorecard* actScorecard;
@property (nonatomic, retain) Scorecard* selScorecard;

- (void) fillScorecards;
- (Scorecard*) scorecardWithName: (NSString*) name AndDate: (NSDate*) date;

@end
