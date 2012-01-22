//
//  HeaderFooterView.h
//  SMTG
//
//  Created by RKing on 6/9/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderFooterView : UIView <UITextFieldDelegate> {
    NSUInteger numCols;
    NSString* headerOrFooter;
    NSArray* playerNamesArr;
    id __unsafe_unretained scoreTracker;
}


enum{
    kNUMHOLE_TAG = 20,
    kPAR_TAG,
    kTOTAL_TAG
};

@property (nonatomic, assign) NSUInteger numCols;
@property (nonatomic, strong) NSString* headerOrFooter;
@property (nonatomic, strong) NSArray* playerNamesArr;
@property (nonatomic, unsafe_unretained) id scoreTracker;

- (void) addHeaderColumnsForNumPlayers: (NSUInteger) numPlayers;
- (void) addFooterColumnsForNumPlayers: (NSUInteger) numPlayers;
- (NSString*) stringOfPlayers;
- (NSString*) stringForNameInCol: (NSUInteger) col;
- (void) setPlayers: (NSArray*) names;

- (void) setTotalsWithScoreDict: (NSMutableDictionary*) scoreDict;

+ (NSUInteger) colFromTag:(NSUInteger)tag HeaderOrFooter: (NSString*) hOrF;

+ (NSString*) appendColIndex: (NSUInteger) ind ToName: (NSString*) name;
+ (NSString*) stripColIndexFromName: (NSString*) text;
+ (NSUInteger) indexFromHeaderText: (NSString*) text;

@end
