//
//  CustomCourseViewController.m
//  ECaddy
//
//  Created by RKing on 7/5/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CustomCourseViewController.h"
#import "Course.h"
#import "ECaddyAppDelegate.h"

@implementation CustomCourseViewController
@synthesize courseNameTF;
@synthesize phoneTF;
@synthesize addressTF;
@synthesize cityTF;
@synthesize stateTF;
@synthesize countryTF;
@synthesize websiteTF;
@synthesize navBar;

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
    // Add save and cancel buttons to the navigation bar
    [self.navBar.topItem setLeftBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action: @selector(cancel)] autorelease]];
    [self.navBar.topItem setRightBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target: self action: @selector(save)] autorelease]];
    
    UIBarButtonItem *barButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:courseNameTF action:@selector(resignFirstResponder)] autorelease];
    UIBarButtonItem *flexibleSpaceLeft = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    toolbar.items = [NSArray arrayWithObjects: flexibleSpaceLeft, barButton, nil];
    [toolbar setBarStyle: UIBarStyleBlackTranslucent];

    self.courseNameTF.inputAccessoryView = toolbar;
}

- (void)viewDidUnload
{
    [self setCourseNameTF:nil];
    [self setPhoneTF:nil];
    [self setAddressTF:nil];
    [self setCityTF:nil];
    [self setStateTF:nil];
    [self setCountryTF:nil];
    [self setWebsiteTF:nil];
    [self setNavBar:nil];
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
    [courseNameTF release];
    [phoneTF release];
    [addressTF release];
    [cityTF release];
    [stateTF release];
    [countryTF release];
    [websiteTF release];
    [navBar release];
    [super dealloc];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"This text field should return");
    
    // Move the keyboard to the next textfield
    NSInteger nextTFTag = textField.tag + 1;
    UITextField* nextTF = (UITextField*) [textField.superview viewWithTag: nextTFTag];
    if(nextTF){
        [nextTF becomeFirstResponder];
    }
    else if((!nextTF) || (textField == websiteTF)){
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - TODO: Uncomment the part where it actually saves to the persistent store
- (void) save
{
    BOOL isValid = YES;
    NSString* errStr = @"The following errors were found:\n";

    if([[self.courseNameTF text] length] == 0){
        errStr = [errStr stringByAppendingString: @"Course Name must not be empty\n"];
        isValid = NO;
    }
    if([[self.cityTF text] length] == 0){
        errStr = [errStr stringByAppendingString: @"City must not be empty\n"];
        isValid = NO;
    }
    if([[self.stateTF text] length] == 0){
        errStr = [errStr stringByAppendingString: @"State must not be empty\n"];
        isValid = NO;
    }
    if([[self.countryTF text] length] == 0){
        errStr = [errStr stringByAppendingString: @"Country must not be empty\n"];
        isValid = NO;
    }
        
    // If there is a current scorecard then display an alert view
    if(!isValid){
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Error" message: errStr delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
        
        [av show];
        return;
    }
    
    // Set the course information and add it to the managed object context
    Course* newCourse = [NSEntityDescription insertNewObjectForEntityForName: @"Course" inManagedObjectContext: [[ECaddyAppDelegate sharedAppDelegate] managedObjectContext]];
    
    // Course Name (Required)
    [newCourse setCoursename: [self.courseNameTF text]];
    
    // Phone Number
    if([[self.phoneTF text] length] != 0){
        // Replace occurrences of (, ), and - with empty strings
        NSString* phoneStr = [[self.phoneTF text] stringByReplacingOccurrencesOfString: @"(" withString:@""];
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString: @")" withString: @""];
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString: @"-" withString: @""];
        [newCourse setPhone: phoneStr];
    }
    else{
        [newCourse setPhone: nil];
    }
    
    // Address City is required (Address, City)
    if([[self.addressTF text] length] != 0){
        NSString* addrStr = [[self.addressTF text] stringByAppendingFormat: @", %@", [self.cityTF text]];
        [newCourse setValue: addrStr forKey: @"address"];
    }
    else{
        [newCourse setValue: [self.cityTF text] forKey: @"address"];
    }

    // State (Required)
    // Try to use a value from the abbreviation dictionary for the state value
    NSString* stateAbbrsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stateabbrs.txt"];
    NSDictionary* abbrsDict = [[NSDictionary alloc] initWithContentsOfFile: stateAbbrsPath];
    NSString* stateVal = [[self.stateTF text] uppercaseString];
    NSUInteger ind = [[abbrsDict allKeys] indexOfObject: stateVal];
    BOOL isStateSet = NO;
    
    if(ind != NSNotFound){
        [newCourse setValue: stateVal forKey: @"state"];
        isStateSet = YES;
    }
    else{
        for(id key in abbrsDict){
            NSString* val = [abbrsDict valueForKey: key];
            if([stateVal caseInsensitiveCompare: val] == NSOrderedSame){
                [newCourse setValue: key forKey: @"state"];
                isStateSet = YES;
            }
        }
    }
    
    if(!isStateSet)
        [newCourse setValue: stateVal forKey: @"state"];
    
    // Country (Required)
    [newCourse setValue: [self.countryTF text] forKey: @"country"];
    
    // Website URL
    if([[self.websiteTF text] length] != 0)
        [newCourse setWebsite: [self.websiteTF text]];
    else
        [newCourse setWebsite: nil];
    
    // Favorite
    [newCourse setValue: [NSNumber numberWithBool: NO] forKey: @"favorite"];
    
    // Enabled
    BOOL isEnabled = [CustomCourseViewController stateEnabled: [newCourse valueForKey: @"state"]];
    [newCourse setValue: [NSNumber numberWithBool: isEnabled] forKey:@"enabled"];
    
    // WOEID
    NSString* woeid = [CustomCourseViewController getWOEIDWithCity: [self.cityTF text] AndState:[newCourse valueForKey: @"state"]];
    [newCourse setWoeid: woeid];
    
    // Save the newly added golf course in the managed object context
    // TODO: This should be uncommented when we actually want to save it
    //[[ECaddyAppDelegate sharedAppDelegate] saveContext];
    
    // Try uploading the course information to the server
    [CustomCourseViewController writeCourseToServer: newCourse];
    
    [abbrsDict release];
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void) cancel
{
    [self dismissModalViewControllerAnimated: YES];
}

+ (BOOL) stateEnabled:(NSString *)state
{
    NSPredicate* predicate = nil;
    BOOL isEnabled = YES;
    
    // Should probably use the name of the default course here
    // Or at least the default state. A random golf course would be weird.
    NSManagedObjectContext* manObjCon = [[ECaddyAppDelegate sharedAppDelegate] managedObjectContext];
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext: manObjCon];
    [fetchrequest setEntity:entity];
    
    predicate = [NSPredicate predicateWithFormat:@"state == %@", state];
    [fetchrequest setPredicate:predicate];
    
    [fetchrequest setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray *array = [manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        if([array count] != 0)
            isEnabled = [[[array objectAtIndex: 0] valueForKey: @"enabled"] boolValue];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];
    
    return isEnabled;
}

+ (NSString*) getWOEIDWithCity: (NSString*) city AndState: (NSString*) state
{
    NSString* woeidStr = nil;

    city = [city stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* urlStr = @"";
    urlStr = [urlStr stringByAppendingString: @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.places%20where%20text%3D%22"];
    urlStr = [urlStr stringByAppendingString: city];
    urlStr = [urlStr stringByAppendingString:@"%20"];
    urlStr = [urlStr stringByAppendingString:state];
    urlStr = [urlStr stringByAppendingString:@"%22&format=xml"];
    
    NSURL* url = [NSURL URLWithString: urlStr];
    NSString* str = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if(!str)
        return nil;
    
    NSRange range1 = [str rangeOfString:@"<woeid>" options:NSLiteralSearch];
    NSRange range2 = [str rangeOfString:@"</woeid>" options:NSLiteralSearch];
    NSRange range3;
    
    if(range1.location == NSNotFound)
        return nil;
    if(range2.location == NSNotFound)
        return nil;
    
    range3.location = range1.location + range1.length;
    range3.length = range2.location - (range1.location+range1.length);
    woeidStr = [str substringWithRange:range3];
    
    NSLog(@"woeid = %@", woeidStr);
    
    [str release];
    
    return woeidStr;
}

#pragma mark - TODO: Finish implementing this stuff

+ (void) writeCourseToServer:(Course *)course
{
    // TODO: Probably don't want to print the description it has a lot of core data
    // information that isn't really needed
    NSString* output = [course description];
    NSURL* url = [NSURL URLWithString:@"http://king.eece.maine.edu/Courses/test.php"];
    NSString* content = [NSString stringWithFormat: @"course=%@", output];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [content dataUsingEncoding: NSUTF8StringEncoding]];
    
    // TODO: This should probably be an asynchronous request to not hold up the UI
    [NSURLConnection sendSynchronousRequest: request returningResponse:nil error:nil];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   /* self.curScorecard.active = [NSNumber numberWithBool: NO];
    ECaddyAppDelegate* del = [ECaddyAppDelegate sharedAppDelegate];
    [del saveContext];
    
    if([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString: @"Continue"]){
        [self beginRound];
    }*/
}

@end
