//
//  ScorecardViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardViewController.h"
#import "NewRoundViewController.h"
#import "ECaddyAppDelegate.h"

@implementation ScorecardViewController


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
    NSLog(@"In ViewDidAppear");
    if(self.courseObj){
        NSLog(@"Not nil");
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
    
    return ret;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (IBAction)startClicked:(id)sender {
   /* DirectoryViewController* dvc = [[DirectoryViewController alloc] initWithNibName:@"StateDirView" bundle:nil];
    
    // Need to provide the managed object context to the directory 
    // to find the available courses and stuff
    NSManagedObjectContext* manObjCon = [(ECaddyAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [dvc setManObjCon: manObjCon];
    [self.navigationController pushViewController: dvc animated:YES];
    [dvc release];
    */
    [self startNewRoundWithCourseOrNil: nil];
}

- (IBAction)continueClicked:(id)sender {

}

- (IBAction)viewClicked:(id)sender {

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
