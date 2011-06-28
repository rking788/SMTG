//
//  HeaderFooterView.h
//  ECaddy
//
//  Created by RKing on 6/9/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderFooterView : UIView <UITextFieldDelegate> {
    NSUInteger numCols;
    NSString* headerOrFooter;
    NSArray* playerNamesArr;
    id scoreTracker;
}


enum{
    kNUMHOLE_TAG = 20,
    kPAR_TAG,
    kTOTAL_TAG
};

@property (nonatomic, assign) NSUInteger numCols;
@property (nonatomic, retain) NSString* headerOrFooter;
@property (nonatomic, retain) NSArray* playerNamesArr;
@property (nonatomic, assign) id scoreTracker;

- (void) addHeaderColumnsForNumPlayers: (NSUInteger) numPlayers;
- (void) addFooterColumnsForNumPlayers: (NSUInteger) numPlayers;
- (NSString*) stringOfPlayers;
- (NSString*) stringForNameInCol: (NSUInteger) col;

- (void) setTotalsWithScoreDict: (NSMutableDictionary*) scoreDict;

+ (NSUInteger) colFromTag:(NSUInteger)tag;

@end
