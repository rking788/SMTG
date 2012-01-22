//
//  ScorecardTableCell.m
//  SMTG
//
//  Created by RKing on 6/11/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardTableCell.h"


@implementation ScorecardTableCell

@synthesize columns;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.columns = [[NSMutableArray alloc] initWithCapacity: 5];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) addColumn:(CGFloat)position
{
    [columns addObject: [NSNumber numberWithFloat: position]];
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Use the same color as the default cell seperator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 1.0);
    
    for (int i = 0; i < [columns count]; i++){
        CGFloat f = [((NSNumber*) [columns objectAtIndex: i]) floatValue];
        CGContextMoveToPoint(ctx, f, 0);
        CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
    }
    
    CGContextStrokePath(ctx);
    
    [super drawRect: rect];
}


@end
