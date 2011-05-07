//
//  WeatherDetails.m
//  ECaddy
//
//  Created by Teacher on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WeatherDetails.h"


@implementation WeatherDetails
@synthesize text;
@synthesize textView;
@synthesize navBar;
@synthesize weatherPic;

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
    [textView release];
    [navBar release];
    [weatherPic release];
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
    [textView setText:text];
    
    self.navBar.topItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    
    // TODO: Remove this stupid thing
    NSURL *url = [NSURL URLWithString:@"http://l.yimg.com/a/i/us/we/52/29.gif"];
    NSData *data = [NSData dataWithContentsOfURL: url];
    UIImage *img = [[UIImage alloc] initWithData: data];
    [self.weatherPic setImage: img];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setNavBar:nil];
    [self setWeatherPic:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
