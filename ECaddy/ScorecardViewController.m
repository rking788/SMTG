 //
//  ScorecardViewController.m
//  SMTG
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardViewController.h"
#import "NewRoundViewController.h"
#import "ScorecardTableViewController.h"
#import "SMTGAppDelegate.h"
#import "Course.h"

@implementation ScorecardViewController

@synthesize uploadingView;
@synthesize contentView;
@synthesize uploadingInd;
@synthesize adView;
@synthesize courseObj;
@synthesize adVisible;
@synthesize pendingCourses;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef LITE
    [self createAdBannerView];
#endif
}

- (void) viewDidAppear:(BOOL)animated
{
    [self checkForPending];
    
    if(self.courseObj){
        [self startNewRoundWithCourseOrNil: self.courseObj];
    }
    
    // This will keep it from going back and forth between the next view controller
    self.courseObj = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
#ifdef LITE
    [self fixupAdView: self.interfaceOrientation];
#endif
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
    
#ifdef LITE
    [self fixupAdView: interfaceOrientation];
#endif
    
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
    [self setPendingCourses: nil];
    [self setUploadingView:nil];
    [self setUploadingInd:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [contentView release];
    [adView release];
    [pendingCourses release];
    [uploadingView release];
    [uploadingInd release];
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

- (void) checkForPending
{
    NSManagedObjectContext* manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext: manObjCon];
    [fetchrequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pending == %@", [NSNumber numberWithBool: YES]];
    [fetchrequest setPredicate:predicate];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"coursename" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSError *error = nil;
    self.pendingCourses = [[manObjCon executeFetchRequest:fetchrequest error:&error] mutableCopy];
    if (self.pendingCourses != nil) {
        if([self.pendingCourses count] != 0){
            // Display the alert view and wait to see if they want to upload the courses now
            NSString* messageStr = @"Courses still need to be uploaded, would you like to upload them now?";
            UIAlertView* av = [[[UIAlertView alloc] initWithTitle: @"Upload Courses" message: messageStr delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", @"Upload", nil] autorelease];
            
            [av show];
        }
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [sortDescript release];
    [sdArr release];
    [fetchrequest release];   
}

- (void) uploadCourseToServer:(Course *)course
{
    BOOL pending = YES;
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSURLResponse* resp = nil;
    NSError* err = nil;
    
    // Add the course information into the POST request content
    NSURL* url = [NSURL URLWithString:@"http://mainelyapps.com/SMTG/NewCourse.php"];
    NSString* content = [NSString stringWithFormat:
                         @"cn=%@&p=%@&addr=%@&st=%@&c=%@&web=%@&woeid=%@&nh=%@", 
                         [course coursename], [course phone], [course valueForKey: @"address"], 
                         [course valueForKey:@"state"], [course valueForKey:@"country"], 
                         [course website], [course woeid], [course numholes]];
    
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL: url] autorelease];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [content dataUsingEncoding: NSUTF8StringEncoding]];
    
    // TODO: This should probably be an asynchronous request to not hold up the UI
    NSData* ret = [NSURLConnection sendSynchronousRequest: request returningResponse: &resp error: &err];
    
    // This return value is used to set the pending value of the course
    if((!ret) || (err))
        pending = YES;
    else
        pending = NO;
    
    [course setPending: [NSNumber numberWithBool: pending]];
    
    // Hide the uploading view
    //[self.uploadingInd stopAnimating];
    //[self.uploadingView setHidden: YES];

    [pool release];

}

- (void) uploadCourses
{
    // Upload all of the courses to the server
    for(Course* gc in self.pendingCourses){
        [self uploadCourseToServer: gc];
    }
    
    // Signal the main thread that we are done getting the weather
    [self performSelectorOnMainThread:@selector(doneUploading) 
                           withObject: nil waitUntilDone: YES];
}

- (void) doneUploading
{
    [[SMTGAppDelegate sharedAppDelegate] saveContext];
    
    // Stop the uploading indicator and hide the views
    [self.uploadingInd stopAnimating];
    [self.uploadingInd setHidden: YES];
    [self.uploadingView setHidden: YES];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString: @"Upload"]){
        [self.uploadingView setHidden: NO];
        [self.uploadingInd setHidden: NO];
        [self.uploadingInd startAnimating];
        
        [NSThread detachNewThreadSelector: @selector(uploadCourses) 
                                 toTarget: self withObject: nil];
    }
}

#pragma mark - iAd methods
#ifdef LITE
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
#endif

@end
