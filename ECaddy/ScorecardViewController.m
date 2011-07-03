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

@implementation ScorecardViewController


@synthesize adView;
@synthesize courseObj;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
- (void) viewDidAppear:(BOOL)animated
{
    if(self.courseObj){
        [self startNewRoundWithCourseOrNil: self.courseObj];
    }
    
    // This will keep it from going back and forth between the next view controller
    self.courseObj = nil;
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
    [self setAdView:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
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

@end
