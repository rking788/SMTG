//
//  CourseDetailViewController.m
//  ECaddy
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "ECaddyAppDelegate.h"
#import "Course.h"

@implementation CourseDetailViewController

@synthesize cdTV;
@synthesize courseObj;
@synthesize favstarBtn;
@synthesize manObjCon;

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
    [favstarBtn release];
    [manObjCon release];
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
    
    // Set the inital state of the favorite star
    BOOL isFav = [[self.courseObj favorite] boolValue];
    [self.favstarBtn setImage: [UIImage imageNamed: (isFav ? @"favstar_selected.png" : 
                                    @"favstar_deselected.png")] forState:UIControlStateNormal];
    
    self.manObjCon = nil;
}

- (void)viewDidUnload
{
    [self setCdTV:nil];
    [self setCourseObj: nil];
    [self setFavstarBtn: nil];
    [self setManObjCon: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void) populateCourseDetails
{
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString: @" ,"];
    NSString* detailText = nil;
    
    NSString* name = self.courseObj.coursename;
    NSString* phone = self.courseObj.phone;
    NSString* website = self.courseObj.website;
    
    // These need to be valueForKeys because they are Location Entities
    NSString* address = [self.courseObj valueForKey: @"address"];
    address = [address stringByTrimmingCharactersInSet: charSet];
    NSString* state = [self.courseObj valueForKey: @"state"];
    
    detailText = [NSString stringWithFormat: @"%@\n%@, %@\n%@", name, address, state, phone];
    
    if(website){
        detailText = [detailText stringByAppendingFormat: @"\n%@", website];
    }
    
    [self.cdTV setText: detailText];
}

- (IBAction)startRoundClicked:(id)sender {
    
    [self.tabBarController setSelectedViewController: [self.tabBarController.viewControllers objectAtIndex: 0]];
    UINavigationController* navCont = (UINavigationController*) self.tabBarController.selectedViewController;
    [[[navCont viewControllers] objectAtIndex: 0] setCourseObj: self.courseObj];
    [navCont popToRootViewControllerAnimated: NO];
    [[[navCont viewControllers] objectAtIndex: 0] viewDidAppear: YES];
    
    return;
}

- (IBAction) favstarPressed:(id)sender
{
    ECaddyAppDelegate* appDel = [ECaddyAppDelegate sharedAppDelegate];
  
    if(!self.manObjCon){
        self.manObjCon = [appDel managedObjectContext];
    }
    
    BOOL fav = [[self.courseObj favorite] boolValue];
 
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstar_selected.png" : 
                                    @"favstar_deselected.png")] forState: UIControlStateNormal];
    
    [self.courseObj setFavorite: [NSNumber numberWithBool: fav]];

    // Save the managed object context to save the favorite change
    [appDel saveContext];
}

@end
