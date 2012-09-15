//
//  ScorePlotViewController.h
//  SMTG
//
//  Created by Rob King on 6/18/12.
//  Copyright (c) 2012 University of Maine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ScorePlotViewController : UIViewController <CPTPlotSpaceDelegate,
CPTPlotDataSource,
CPTScatterPlotDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) CPTLayerAnnotation   *symbolTextAnnotation;

- (void) generateData;
- (void) generateScatterPlot;

@end
