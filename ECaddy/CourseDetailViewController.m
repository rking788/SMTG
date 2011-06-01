//
//  CourseDetailViewController.m
//  ECaddy
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseDetailViewController.h"


@implementation CourseDetailViewController

@synthesize cdTV;
@synthesize courseObj;

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
    [cdTV release];
    [courseObj release];
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

    [self.navigationItem setTitle: @"Course Info"];
    
    // Populate the details in the view
    [self populateCourseDetails];
}

- (void)viewDidUnload
{
    [self setCdTV:nil];
    [self setCourseObj: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) populateCourseDetails
{
    NSString* name = nil;
    NSString* phone = nil;
    NSString* website = nil;
    NSString* address = nil;
    NSString* state = nil;
    NSString* detailText = nil;
    
    name = [self.courseObj valueForKey: @"coursename"];
    phone = [self.courseObj valueForKey: @"phone"];
    website = [self.courseObj valueForKey: @"website"];
    address = [self.courseObj valueForKey: @"address"];
    state = [self.courseObj valueForKey: @"state"];
    
    detailText = [NSString stringWithFormat: @"%@\n%@, %@\n%@", name, address, state, phone];
    
    if(website){
        detailText = [detailText stringByAppendingFormat: @"\n%@", website];
    }
    
    [self.cdTV setText: detailText];
    
}

@end
