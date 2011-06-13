//
//  ScorecardTableCell.h
//  ECaddy
//
//  Created by RKing on 6/11/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScorecardTableCell : UITableViewCell {
    NSMutableArray* columns;
}

@property (nonatomic, retain) NSMutableArray* columns;

- (void) addColumn: (CGFloat) position;

@end
