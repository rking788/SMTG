//
//  ScorePlotViewController.m
//  SMTG
//
//  Created by Rob King on 6/18/12.
//  Copyright (c) 2012 University of Maine. All rights reserved.
//

#import "ScorePlotViewController.h"

@implementation ScorePlotViewController

#define BAR_POSITION @"POSITION"
#define BAR_HEIGHT @"HEIGHT"
#define COLOR @"COLOR"
#define CATEGORY @"CATEGORY"

#define AXIS_START 0
#define AXIS_END 50

@synthesize data;
@synthesize graph;
@synthesize hostingView;
@synthesize symbolTextAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self generateScatterPlot];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void) generateData
{
    double max = 0.0f, min = 10000.0f;
    if (self.data == nil) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < 10; i++) {
            id x = [NSNumber numberWithInteger: i];
            id y = [NSNumber numberWithDouble: (rand() % 80) + 1];
            if([y doubleValue] > max)
                max = [y doubleValue];
            if ([y doubleValue] < min)
                min = [y doubleValue];
            [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
        }
        
        data = contentArray;
        
        NSLog(@"Min = %lf\nMax = %lf", min, max);
    }
}

- (void) generateScatterPlot
{
    //Create host view
    self.hostingView = [[CPTGraphHostingView alloc] 
                        initWithFrame:[[UIScreen mainScreen]bounds]];
    [self.view addSubview: self.hostingView];
    
    //Create graph and set it as host view's graph
    self.graph = [[CPTXYGraph alloc] initWithFrame: self.hostingView.bounds];
    [self.hostingView setHostedGraph: self.graph];
    
    CGRect bounds = self.hostingView.bounds;
    
    [self.graph applyTheme:[CPTTheme themeNamed: kCPTStocksTheme]];
    
    // Setup the graph title
    self.graph.title = @"Golf Course Name";
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = bounds.size.height / 20.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, bounds.size.height / 18.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Set padding defaults
    float boundsPadding = bounds.size.width / 20.0f;
    graph.paddingLeft = boundsPadding;
    
    if (graph.titleDisplacement.y > 0.0) {
        graph.paddingTop = graph.titleDisplacement.y * 2;
    }
    else {
        graph.paddingTop = boundsPadding;
    }
    
    graph.paddingRight = boundsPadding;
    graph.paddingBottom = boundsPadding;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    /*x.majorIntervalLength = CPTDecimalFromString(@"0.5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1.0");
    x.minorTicksPerInterval = 2;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    
    x.title = @"X Axis";
    x.titleOffset = 30.0;
    x.titleLocation = CPTDecimalFromString(@"1.25");
    */
    // Label y with an automatic label policy. 
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1.0");
    y.minorTicksPerInterval = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelOffset = 10.0;
    
    y.title = @"Y Axis";
    y.titleOffset = 30.0;
    y.titleLocation = CPTDecimalFromString(@"1.0");
    
    // Rotate the labels by 45 degrees, just to show it can be done.
//    labelRotation = M_PI * 0.25;
    
    // Set axes
    //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Data Source Plot";
    CPTMutableLineStyle* newlinestyle = [CPTMutableLineStyle lineStyle];
    newlinestyle.lineWidth = 3.0;
    newlinestyle.lineColor = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = newlinestyle;
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    [self generateData];
    
    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:dataSourceLinePlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.3)];
    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.3)];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;
    
    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
    plotSpace.globalYRange = globalYRange;
    
    // set the x and y shift to match the new ranges
    CGFloat length = xRange.lengthDouble;
//    xShift = length - 3.0;
    length = yRange.lengthDouble;
//    yShift = length - 2.0;
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor: [CPTColor blueColor]];
    plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self; 
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0f;
}

#pragma mark - Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [data count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = [[data objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    if (fieldEnum == CPTScatterPlotFieldY) {
        //num = [NSNumber numberWithDouble:[num doubleValue]];
    }
    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if (coordinate == CPTCoordinateX) {
       /* CPTMutablePlotRange *maxRange = [CPTMutablePlotRange plotRangeWithLocation: CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(6.0f)];
        CPTMutablePlotRange *changedRange = [newRange mutableCopy];
        [changedRange shiftEndToFitInRange:maxRange];
        [changedRange shiftLocationToFitInRange:maxRange];
        newRange = changedRange;
   */
    }
    
    return newRange;
}

#pragma mark -
#pragma mark CPScatterPlot delegate method

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *locGraph = self.graph;
    
    if (self.symbolTextAnnotation) {
        [locGraph.plotAreaFrame.plotArea removeAnnotation: symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [[data objectAtIndex:index] valueForKey:@"x"];
    NSNumber *y = [[data objectAtIndex:index] valueForKey:@"y"];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText: yString style:hitAnnotationTextStyle];
    self.symbolTextAnnotation = (CPTLayerAnnotation*)[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:locGraph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    self.symbolTextAnnotation.contentLayer = textLayer;
    self.symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [locGraph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}

@end
