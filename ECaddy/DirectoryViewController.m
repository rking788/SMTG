//
//  DirectoryViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "DirectoryViewController.h"
#import "CourseSelectViewController.h"
#import "ECaddyAppDelegate.h"
#import "Course.h"
#import "CourseDetailViewController.h"
#import "WeatherDetails.h"
#import "SettingsViewController.h"
#import "SettingsDetailsViewController.h"
#import "CustomCourseViewController.h"

@implementation DirectoryViewController

@synthesize stateSet, countrySet, abbrsDict, stateArrDict;
@synthesize favoriteNames, favoriteLocs;
@synthesize courseSelectDelegate;
@synthesize theTable;
@synthesize manObjCon;
@synthesize modal;
@synthesize settingsDetailType;
@synthesize appDel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Get the app delegate to find an active course or not
    self.appDel = [ECaddyAppDelegate sharedAppDelegate];
    
    // Get the managed object context from the app delegate
    self.manObjCon = [(ECaddyAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    // Initialize abbreviation dictionary
    NSString* stateAbbrsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stateabbrs.txt"];
    self.abbrsDict = [[NSDictionary alloc] initWithContentsOfFile: stateAbbrsPath];
    
    // Allocate the favorites arrays
    self.favoriteNames = [[NSMutableArray alloc] init];
    self.favoriteLocs = [[NSMutableArray alloc] init];
    
    // Fill state and country sets
    [self fillStatesCountries];
    
    self.theTable.backgroundColor = [UIColor clearColor];
    
    [self.navigationItem setTitle: @"State Select"];

    // If the view controller is presented modally we want to provide a 
    // cancel button or done button in the navigation bar
    if([self isModal]){
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(modalCancel:)] autorelease];
    }
    
    // Check for a valid default state and possibly just skip to CourseSelectVC
    NSUserDefaults* defaultPrefs = [NSUserDefaults standardUserDefaults];
    if([defaultPrefs stringForKey: @"state"] && (self.settingsDetailType != kSTATE_EDIT))
        [self gotoCourseSelectWithState: [defaultPrefs stringForKey: @"state"] Animate: NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.favoriteNames removeAllObjects];
    [self.favoriteLocs removeAllObjects];
    
    [self fillFavorites];
    [self.theTable reloadData];
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
    [self setTheTable:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.stateSet = nil;
    self.countrySet = nil;
    self.abbrsDict = nil;
    self.stateArrDict = nil;
    self.favoriteNames = nil;
    self.favoriteLocs = nil;
    self.appDel = nil;
}

- (void)dealloc
{
    [stateSet release];
    [countrySet release];
    [abbrsDict release];
    [stateArrDict release];
    [favoriteNames release];
    [favoriteLocs release];
    [theTable release];
    [appDel release];
    [super dealloc];
}

- (void) fillFavorites
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    [fetchrequest setResultType: NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]];
    [fetchrequest setPredicate:predicate];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"coursename" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSDictionary* entityProps = [entity propertiesByName];
    NSArray* propArr = [[NSArray alloc] initWithObjects: [entityProps objectForKey: @"coursename"],
                        [entityProps objectForKey: @"address"], [entityProps objectForKey: @"state"], nil];
    [fetchrequest setPropertiesToFetch: propArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* nameStr = nil;
        NSString* locStr = nil;

        for(NSManagedObject* manObj in array){
            
            nameStr = [manObj valueForKey: @"coursename"];
            locStr = [[[manObj valueForKey: @"address"]
                      stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" ,"]]
                      stringByAppendingFormat: @",%@", [manObj valueForKey: @"state"]];
            
            [self.favoriteNames addObject: nameStr];
            [self.favoriteLocs addObject: locStr];
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [sortDescript release];
    [sdArr release];
    [propArr release];
    [fetchrequest release];   
}

- (void) fillStatesCountries
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    if(self.settingsDetailType != kSTATE_EDIT){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enabled == %@", [NSNumber numberWithBool: YES]];
        [fetchrequest setPredicate:predicate];
    }
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* state = nil;
        NSString* country = nil;
        NSMutableSet* sSet = [[NSMutableSet alloc] init];
        NSMutableSet* cSet = [[NSMutableSet alloc] init];
        NSMutableDictionary* saDict = [[NSMutableDictionary alloc] init];
        NSMutableArray* tmpArr = nil;
        
        for(NSManagedObject* manObj in array){
            country = [manObj valueForKey: @"country"];
            state = [manObj valueForKey: @"state"];
            
            if((![sSet member: state]) && [cSet member: country]){
                tmpArr = (NSMutableArray*) [saDict valueForKey: country];
                [tmpArr addObject:state];
                [saDict setValue: tmpArr forKey: country];
            }
            else if(![cSet member: country]) {
                tmpArr = [[NSMutableArray alloc] initWithObjects: state, nil];
                [saDict setObject: tmpArr forKey: country];
                [tmpArr release]; tmpArr = nil;
            }
            
            [cSet addObject: country];
            [sSet addObject: state];
        }
    
        self.stateSet = [[NSSet alloc] initWithSet: sSet];
        self.countrySet = [[NSSet alloc] initWithSet: cSet];
        self.stateArrDict = [[NSDictionary alloc] initWithDictionary: saDict];
        
        [sSet release]; sSet = nil;
        [cSet release]; cSet = nil;
        [saDict release]; saDict = nil;
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];
    [sdArr release];
    [sortDescript release];
}

#pragma mark UITableViewDataSource Protocol Methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // This means the new course detail button was clicked so display the modal view to add a course
    [self courseCreateModal];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retInt = -1;
    NSInteger newSection = section;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([self.favoriteNames count] != 0) ? YES : NO;
    
    // Always subtract one for the new course section
    newSection--;
    if(section == 0)
        retInt = 1;
    
    if(isActives){
        newSection--;
        
        if(section == 1)
            retInt = 1;
    }
    
    if(isFavs){
        newSection--;
        
        if((section == 1) && (!isActives))
            retInt = [favoriteNames count];
        else if((section == 2) && (isActives))
            retInt = [favoriteNames count];
    }
    
    // Not in an active course 
    if(retInt == -1){
        NSString* countryStr = [[countrySet allObjects] objectAtIndex: newSection];
        retInt = [[stateArrDict objectForKey: countryStr] count];
    }

    return retInt;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retInt = -1;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([favoriteNames count] != 0) ? YES : NO;
    
    retInt = [self.countrySet count];
    
    // Always add one for the new course section
    retInt++;
    
    if(isActives)
        retInt++;
    
    if(isFavs)
        retInt++;
    
    return retInt;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self tableView: tableView viewForHeaderInSection: section] == nil)
        return 0;
    else
        return 40;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    
    if([self tableView: tableView titleForHeaderInSection: section] == nil)
        return nil;
    
    lbl.frame = CGRectMake( 15, 0, 300, 40);
    [lbl setText: [self tableView: tableView titleForHeaderInSection: section]];
    [lbl setTextColor: [UIColor whiteColor]];
    [lbl setBackgroundColor: [UIColor clearColor]];
    [lbl setFont: [UIFont fontWithName: @"Georgia Bold" size: 20.0]];
    lbl.shadowColor = [UIColor blackColor];
    lbl.shadowOffset = CGSizeMake(0.0, 1.0);
    
    UIView* view = [[[UIView alloc] init] autorelease];
    [view addSubview: (UIView*) lbl];
    
    return view;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString* retStr = nil;
    NSInteger newSection = section;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([self.favoriteNames count] != 0) ? YES : NO;
    
    // Need to always subtract one because of the new course section
    newSection--;
    if(section == 0){
        retStr = @"New Course";
    }
    
    if(isActives){
        newSection--;
        
        if(section == 1)
            retStr = @"Active";
    }
    
    if(isFavs){
        newSection--;
        
        if((section == 1) && (!isActives))
            retStr = @"Favorites";
        else if((section == 2) && (isActives))
            retStr = @"Favorites";
    }
    
    if(retStr == nil){
        NSString* countryAbbr = [[countrySet allObjects] objectAtIndex: newSection];
        retStr = [self.abbrsDict valueForKey: countryAbbr];
    }
    
    return retStr; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([self.favoriteNames count] != 0) ? YES : NO;
    BOOL isActCell = NO, isFavsCell = NO, isNewCourseCell = NO;
    NSInteger newSection = indexPath.section;
    
    newSection--;
    if(indexPath.section == 0)
        isNewCourseCell = YES;
    
    if(isActives){
        newSection--;
        
        if(indexPath.section == 1)
            isActCell = YES;
    }
    
    if(isFavs){
        newSection--;
        
        if(((indexPath.section == 1) && (!isActives)) || ((indexPath.section == 2) && (isActives)))
            isFavsCell = YES;
    }

    [tableView deselectRowAtIndexPath: indexPath animated:NO];
        
    if(isNewCourseCell){
        // Display the modal view to add a course
        [self courseCreateModal];
    }
    else if(isActCell || isFavsCell){
        NSString* courseName = [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text];
        Course* courseObject = [CourseSelectViewController courseObjectWithName: courseName
                                InContext: self.manObjCon];
        
        UITableViewCell* tVC = [tableView cellForRowAtIndexPath: indexPath];
        UITabBarController* tbc = [[ECaddyAppDelegate sharedAppDelegate] tabBarController];
        UITabBarItem* tbi = [[tbc tabBar] selectedItem];
        NSString* tabItemTitle = [tbi title];
        
        if([tabItemTitle isEqualToString: @"Scorecards"]){
            // Notify the New Round View Controller that a course was selected
            [self.courseSelectDelegate selectCourse: courseObject];
        }
        else if([tabItemTitle isEqualToString: @"Directory"]){
            // Display the course details
            CourseDetailViewController* cdvc = [[CourseDetailViewController alloc] initWithNibName:@"CourseDetailView" bundle:nil];
            
            [cdvc setCourseObj: courseObject];
            [self.navigationController pushViewController:cdvc animated:YES];
            [cdvc release];
        }
        else if([tabItemTitle isEqualToString: @"Weather"]){
            WeatherDetails* weatherView = [[WeatherDetails alloc] initWithNibName:@"WeatherDetails" bundle:nil];
            
            // Set the course detail information from the selected tableview cell
            NSString* woeid = [courseObject valueForKey: @"woeid"];
            [weatherView setCourseName: [[tVC textLabel] text]];
            [weatherView setCourseLoc: [[tVC detailTextLabel] text]];
            [weatherView setCourseObj: courseObject];
            [weatherView setWOEID: woeid];
            
            // Set the transition mode and display the weather detail view modally
            [weatherView setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
            [self presentModalViewController:weatherView animated:YES];
            [weatherView release];
        }
        else if([tabItemTitle isEqualToString: @"Settings"]){
            // Notify the settings that a course was selected
            [self.courseSelectDelegate selectCourse: courseObject];
        }
        
    }
    else{
        if(self.settingsDetailType == kSTATE_EDIT){
            NSString* countryStr = [[countrySet allObjects] objectAtIndex: newSection];
            NSString* stateStr = [[stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
            [(SettingsViewController*) self.courseSelectDelegate saveState: stateStr];

            return;
        }
        
        NSString* countryStr = [[self.countrySet allObjects] objectAtIndex: newSection];
        NSString* stateStr = [[self.stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
        [self gotoCourseSelectWithState: stateStr Animate: YES];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* NewCourseCellIdentifier = @"NewCourseTableCell";
    static NSString* StateCellIdentifier = @"StateTableCell";
    static NSString* ActiveFavsCellIdentifier = @"ActFavsTableCell";
    UITableViewCell* cell = nil;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([self.favoriteNames count] != 0) ? YES : NO;
    BOOL isActCell = NO, isFavCell = NO;
    BOOL isNewCourseCell = NO;
    NSUInteger sect = indexPath.section;
    NSInteger newSection = indexPath.section;
    
    // Top three sections are special
    newSection--;
    if(indexPath.section == 0)
        isNewCourseCell = YES;
    
    if(isActives){
        newSection--;
        
        if(sect == 1){
            isActCell = YES;
        }
    }
    
    if(isFavs){
        newSection--;
        
        if(((sect == 1) && (!isActives)) || ((sect == 2) && (isActives))){
            isFavCell = YES;
        }
    }
    
    if(isNewCourseCell){
        cell = [tableView dequeueReusableCellWithIdentifier: NewCourseCellIdentifier];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: NewCourseCellIdentifier] autorelease];
        }
        UILabel* lbl = [cell textLabel];
        
        [lbl setText: @"Add a new course"];
        
    }
    else if(isActCell || isFavCell){
        cell = [tableView dequeueReusableCellWithIdentifier: ActiveFavsCellIdentifier];
        if(!cell)
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: ActiveFavsCellIdentifier] autorelease];
        
        UILabel* lbl = [cell textLabel];   
        UILabel* subLbl = [cell detailTextLabel];
        
        if(isActCell){
            [lbl setText: [self.appDel.curCourse coursename]];
            [subLbl setText: [self.appDel.curCourse valueForKey: @"address"]];
        }
        else if(isFavCell){
            [lbl setText: [self.favoriteNames objectAtIndex: indexPath.row]];
            [subLbl setText: [self.favoriteLocs objectAtIndex: indexPath.row]];
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:StateCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:StateCellIdentifier] autorelease];
        }

        UILabel* lbl = [cell textLabel];
        
        // Set the contents of the cell to be the state name with a little arrow indicating more details
        NSString* countryStr = [[self.countrySet allObjects] objectAtIndex: newSection];
        NSString* stateStr = [[self.stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
        
        NSString* longState = [abbrsDict valueForKey: stateStr];
        if(longState)
            [lbl setText: longState];
        else
            [lbl setText: stateStr];
    }

    if (isNewCourseCell)
        [cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
    else
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void) modalCancel: (id) sender
{
    [self.courseSelectDelegate selectCourse: nil];
}

- (void) gotoCourseSelectWithState: (NSString*) stateAbbr Animate:(BOOL) animated
{
    // If the default state isn't enabled then we don't want to go to that course
    // select page
    if(![[self.stateSet allObjects] containsObject: stateAbbr])
        return;
    
    CourseSelectViewController* csvc = [[CourseSelectViewController alloc] initWithNibName:@"CourseSelectView" bundle:nil];
    
    if([self isModal])
        csvc.modal = YES;
    else
        csvc.modal = NO;
    
    NSString* longState = [self.abbrsDict valueForKey: stateAbbr];
    
    csvc.selectedState = stateAbbr;
    
    if(longState)
        csvc.longStateName = [self.abbrsDict valueForKey: stateAbbr];
    else
        csvc.longStateName = stateAbbr;
    
    csvc.courseSelectDelegate = self.courseSelectDelegate;
    csvc.manObjCon = self.manObjCon;
    
    [self.navigationController pushViewController:csvc animated: animated];

    [csvc release];
}

- (void) courseCreateModal
{   
    CustomCourseViewController* ccvc = [[CustomCourseViewController alloc] initWithNibName: @"CustomCourseView" bundle: nil];
    
    [self presentModalViewController: ccvc animated: YES];
    [ccvc release];
}

@end
