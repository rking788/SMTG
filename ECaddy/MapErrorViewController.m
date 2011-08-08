//
//  MapErrorViewController.m
//  ECaddy
//
//  Created by Robert King on 8/7/11.
//  Copyright (c) 2011 University of Maine. All rights reserved.
//

#import "MapErrorViewController.h"

static NSString* CONTACTEMAIL = @"admin@mainelyapps.com";

@implementation MapErrorViewController
@synthesize navBar;
@synthesize messageTV;
@synthesize actionBtn;
@synthesize coursename;
@synthesize courselocation;
@synthesize err;
@synthesize caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    // Add the right bar button item for a done button to dismiss the modal view 
    [navBar setRightBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target: self action: @selector(doneBtnClicked)] autorelease]];
    
    if([self.err isEqualToString: @"NoActiveCourse"])
        [self noActiveCourse];
    else if([self.err isEqualToString: @"NoCoordsAvailable"])
        [self noCoordsAvailable];

}

- (void)viewDidUnload
{
    [self setMessageTV:nil];
    [self setActionBtn:nil];
    [self setNavBar:nil];
    [self setCoursename: nil];
    [self setCourselocation: nil];
    [self setErr: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [messageTV release];
    [actionBtn release];
    [navBar release];
    [coursename release];
    [courselocation release];
    [err release];
    [caller release];
    [super dealloc];
}


- (IBAction) btnClicked:(id)sender 
{
    if([[[self.actionBtn titleLabel] text] isEqualToString: @"Start Round"]){
        [self dismissModalViewControllerAnimated: YES];
        
        [self.caller startNewRound];
    }
    else if([self.actionBtn.titleLabel.text isEqualToString: @"EMail Request"]){
        NSString* subjectStr = @"Coordinates%20Request";
        
        NSString* bodyStr = [NSString stringWithFormat: @"I would like to request coordinates for %@ with the following address: %@", self.coursename, self.courselocation];
        bodyStr = [bodyStr stringByReplacingOccurrencesOfString: @" " withString:@"%20"];
        
        NSString* urlStr = [NSString stringWithFormat: @"mailto:%@?subject=%@&body=%@", CONTACTEMAIL, subjectStr, bodyStr];

        NSURL* url = [NSURL URLWithString: urlStr];
        [[UIApplication sharedApplication] openURL: url];
        
        [self dismissModalViewControllerAnimated: YES];
    }
}

- (void) noActiveCourse
{
    NSString* errorStr = @"It seems that there is no currently active round.\n\nPlease go to the \"Scorecards\" tab to begin a round or press the button below.\n\nThen you will be able to view the course here, if coordinates are available.";
    
    [self.messageTV setText: errorStr];
    [self.actionBtn setTitle: @"Start Round" forState: UIControlStateNormal];
}

- (void) noCoordsAvailable
{
    NSString* errorStr = @"Unfortunately, coordinates are not available for this course.\n\nClick the button below to send an EMail to the administrator to request coordinates for this course.\n\nIn the future there will be a way to log the coordinates while on the course.";
    
    [self.messageTV setText: errorStr];
    [self.actionBtn setTitle: @"EMail Request" forState: UIControlStateNormal];
}

- (void) doneBtnClicked
{
    [self dismissModalViewControllerAnimated: YES];
}

@end
