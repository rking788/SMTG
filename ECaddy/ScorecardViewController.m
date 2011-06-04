//
//  ScorecardViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardViewController.h"
//#import "DirectoryViewController.h"
#import "NewRoundViewController.h"
#import "ECaddyAppDelegate.h"

@implementation ScorecardViewController


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
    NewRoundViewController* nrvc = [[NewRoundViewController alloc] initWithNibName: @"NewRoundView" bundle:nil];
    [self.navigationController pushViewController:nrvc animated:YES];
    [nrvc release];
}

- (IBAction)continueClicked:(id)sender {
}

- (IBAction)viewClicked:(id)sender {
}
@end
