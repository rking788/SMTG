 //
//  ScorecardViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardViewController.h"
#import "NewRoundViewController.h"
#import "ScorecardTableViewController.h"
#import "Course.h"

@implementation ScorecardViewController

@synthesize contentView;
@synthesize adView;
@synthesize courseObj;
@synthesize adVisible;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createAdBannerView];
}

- (void) viewDidAppear:(BOOL)animated
{
    if(self.courseObj){
        [self startNewRoundWithCourseOrNil: self.courseObj];
    }
    
    // This will keep it from going back and forth between the next view controller
    self.courseObj = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self fixupAdView: self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL ret = NO;
    
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        ret = YES;
    }
    else if(interfaceOrientation == UIInterfaceOrientationPortrait){
        ret = YES;
    }
    
    [self fixupAdView: interfaceOrientation];
    
    //return ret;
    return YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setContentView: nil];
    [self setAdView:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [contentView release];
    [adView release];
    [super dealloc];
}

- (IBAction)startClicked:(id)sender {
    [self startNewRoundWithCourseOrNil: nil];
}

- (IBAction)continueClicked:(id)sender
{
    ScorecardTableViewController* nrvc = [[ScorecardTableViewController alloc] initWithNibName: @"ScorecardTableView" bundle:nil];
    
    nrvc.navigationItem.title = @"Continue";
    [self.navigationController pushViewController:nrvc animated:YES];
    [nrvc release];  
}

- (IBAction)viewClicked:(id)sender
{
    ScorecardTableViewController* nrvc = [[ScorecardTableViewController alloc] initWithNibName: @"ScorecardTableView" bundle:nil];
    
    nrvc.navigationItem.title = @"View";
    [self.navigationController pushViewController:nrvc animated:YES];
    [nrvc release];  
}

- (void) startNewRoundWithCourseOrNil: (Course*) course
{
    NewRoundViewController* nrvc = [[NewRoundViewController alloc] initWithNibName: @"NewRoundView" bundle:nil];
    
    if(course)
        [nrvc setCurCourse: course];
    
    [self.navigationController pushViewController:nrvc animated:YES];
    [nrvc release];    
}

#pragma mark iAd methods
- (int)getBannerHeight:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight: self.interfaceOrientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adView = [[[classAdBannerView alloc] 
                              initWithFrame:CGRectZero] autorelease];
        [adView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
                                                          ADBannerContentSizeIdentifierPortrait, 
                                                          ADBannerContentSizeIdentifierLandscape, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];            
        }
        [adView setFrame:CGRectOffset([adView frame], 0, -[self getBannerHeight])];
        [adView setDelegate:self];
        
        [self.view addSubview:adView];        
    }
}

- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (adView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierLandscape];
        } else {
            [adView setCurrentContentSizeIdentifier:
             ADBannerContentSizeIdentifierPortrait];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (adVisible) {
            CGRect adBannerViewFrame = [adView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 0;
            [adView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 
            [self getBannerHeight:toInterfaceOrientation];
            contentViewFrame.size.height = self.view.frame.size.height - 
            [self getBannerHeight:toInterfaceOrientation];
            contentView.frame = contentViewFrame;
        } else {
            CGRect adBannerViewFrame = [adView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
            [adView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            contentView.frame = contentViewFrame;            
        }
        [UIView commitAnimations];
    }   
}

#pragma mark ADBannerViewDelegate Methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"A Banner was loaded");
    
    if (!adVisible){                
        adVisible = YES;
        [self fixupAdView: self.interfaceOrientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to load a banner");
    
    if (adVisible){        
        adVisible = NO;
        [self fixupAdView: self.interfaceOrientation];
    }
}

@end
