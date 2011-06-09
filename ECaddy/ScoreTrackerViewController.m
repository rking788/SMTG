//
//  ScoreTrackerViewController.m
//  ECaddy
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScoreTrackerViewController.h"


@implementation ScoreTrackerViewController

@synthesize headerTextView;
@synthesize scorecard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [scorecard release];
    [headerTextView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(self.scorecard){
        NSString* name;
        NSString* date;
        NSDateFormatter* dateF;
        
        name = [[self.scorecard course] coursename];
        dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat: @"MM/dd/yyyy hh:mm"];
        
        date = [dateF stringFromDate: [self.scorecard dateplayed]];
        [self.headerTextView setText: [NSString stringWithFormat: @"%@\n%@", name, date]];
    }
}

- (void)viewDidUnload
{
    [self setHeaderTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scorecard = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
