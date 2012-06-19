//
//  CourseSelectViewController.m
//  SMTG
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseSelectViewController.h"
#import "CourseDetailViewController.h"
#import "WeatherDetails.h"
#import "SMTGAppDelegate.h"
#import "CustomCourseViewController.h"

@implementation CourseSelectViewController

@synthesize arrayOfChars, coursesDict;
@synthesize nameSearch;
@synthesize selectedState, longStateName;
@synthesize favoriteLocs, favoriteNames;
@synthesize manObjCon;
@synthesize searchB;
@synthesize tableV;
@synthesize blackView;
@synthesize searching;
@synthesize appDel;
@synthesize courseSelectDelegate;
@synthesize modal;

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
    
    // Set the app delegate to find if there is an active course or not
    [self setAppDel: [SMTGAppDelegate sharedAppDelegate]];
    
    // Set the title in the navigation bar
    if(self.selectedState)
        [self.navigationItem setTitle: self.longStateName];
    else
        [self.navigationItem setTitle:@"Course Select"];
    
    self.coursesDict = [[NSMutableDictionary alloc] initWithCapacity: 26];
    self.arrayOfChars = [[NSMutableArray alloc] initWithCapacity: 26];
    
    self.nameSearch = [[NSMutableArray alloc] init];
    
    self.favoriteNames = [[NSMutableArray alloc] init];
    self.favoriteLocs = [[NSMutableArray alloc] init];
    
    // Fill the favorite courses
    [self fillFavorites];
    
    // Fill the course names and locations
    [self fillNamesAndLocs];
    
    /*
     Create and configure the four recognizers. Add each to the view as a gesture recognizer.
     */
    UIGestureRecognizer *recognizer;
    
    /*
     Create a tap recognizer and add it to the view.
     Keep a reference to the recognizer to test in gestureRecognizer:shouldReceiveTouch:.
     */
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.blackView addGestureRecognizer:recognizer];
    
    self.searching = NO;

    // If the view controller is presented modally we want to provide a 
    // cancel button or done button in the navigation bar
    if([self isModal]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(modalCancel:)];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableV setAlwaysBounceVertical: YES];
    
    [self.favoriteNames removeAllObjects];
    [self.favoriteLocs removeAllObjects];
    
    [self fillFavorites];
    [self.tableV reloadData];
}


- (void)viewDidUnload
{
    [self setSearchB:nil];
    [self setTableV:nil];
    [self setBlackView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setCoursesDict: nil];
    [self setArrayOfChars: nil];
    [self setLongStateName: nil];
    [self setAppDel: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void) fillFavorites
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    [fetchrequest setResultType: NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == %@ AND state == %@", [NSNumber numberWithBool: YES], self.selectedState];
    [fetchrequest setPredicate:predicate];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"coursename" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSDictionary* entityProps = [entity propertiesByName];
    NSArray* propArr = [[NSArray alloc] initWithObjects: [entityProps objectForKey: @"coursename"],
                        [entityProps objectForKey: @"address"], nil];
    [fetchrequest setPropertiesToFetch: propArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* nameStr = nil;
        NSString* locStr = nil;
        
        for(NSManagedObject* manObj in array){
            
            nameStr = [manObj valueForKey: @"coursename"];
            locStr = [manObj valueForKey: @"address"];
            
            [self.favoriteNames addObject: nameStr];
            [self.favoriteLocs addObject: locStr];
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
}

- (void) fillNamesAndLocs
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@", self.selectedState];
    [fetchrequest setPredicate:predicate];
    
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"coursename" ascending: YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSDictionary* entityProps = [entity propertiesByName];
    NSArray* propArr = [[NSArray alloc] initWithObjects: [entityProps objectForKey: @"coursename"], [entityProps objectForKey: @"address"], nil];
    [fetchrequest setPropertiesToFetch: propArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* nameStr = nil;
        NSString* locStr = nil;
        NSString* firstCharStr = nil;
        NSString* combinedStr = nil;
        NSMutableArray* tmpArr = nil;
        
        for(NSManagedObject* manObj in array){
            tmpArr = nil;
            
            nameStr = [manObj valueForKey: @"coursename"];
            locStr = [[manObj valueForKey: @"address"] stringByTrimmingCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:@" ,"]];
            combinedStr = [nameStr stringByAppendingFormat: @";%@", locStr];
            firstCharStr = [nameStr substringToIndex: 1];
            
            if([self.arrayOfChars containsObject: firstCharStr]){
                tmpArr = (NSMutableArray*) [self.coursesDict objectForKey: firstCharStr];
                [tmpArr addObject: combinedStr];
                [self.coursesDict setObject: tmpArr forKey: firstCharStr];
            }
            else{
                [self.arrayOfChars addObject: firstCharStr];
                tmpArr = [[NSMutableArray alloc] initWithObjects: combinedStr, nil];
                [self.coursesDict setObject: tmpArr forKey: firstCharStr];
                 tmpArr = nil;
            }
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching course names and locations");
    }
    
}

#pragma mark UITableViewDataSource Protocol Methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // This means the new course detail button was clicked so display the modal view to add a course
    [self courseCreateModal];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* retStr = nil;
    NSInteger newSection = section;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([favoriteNames count] != 0) ? YES : NO;
    
    if(self.searching){
        retStr = @"";
        return retStr;
    }
    
    // Need to always subtract one for the new course section
    newSection--;
    if(section == 0)
        retStr = @"New Course";
    
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
         retStr = [self.arrayOfChars objectAtIndex: newSection];
    }
    
    return retStr;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retInt = 1;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([favoriteNames count] != 0) ? YES : NO;
    
    if(self.searching)
        return 1;
    
    retInt = [self.arrayOfChars count];
    
    // Always add one for the new course section
    retInt++;
    
    if(isActives)
        retInt++;
    if(isFavs)
        retInt++;
    
    return retInt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = -1;
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([self.favoriteNames count] != 0) ? YES : NO;
    NSInteger newSection = section;
    
    // Always subtract one for the new course section
    newSection--;
    
    if(self.searching && ([self.searchB.text length] > 0)){
        num = [self.nameSearch count];
        return num;
    }
    
    if(isActives){
        newSection--;
        
        if(section == 1)
            num = 1;
    }
    
    if(isFavs){
        newSection--;
        
        if((section == 1) && (!isActives))
            num = [favoriteNames count];
        else if((section == 2) && (isActives))
            num = [favoriteNames count];
    }
    
    if(section == 0)
        num = 1;
    
    if(num == -1)
        num = [[self.coursesDict objectForKey: [self.arrayOfChars objectAtIndex: newSection]] count];
    
    return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];
    
    UITableViewCell* tVC = [tableView cellForRowAtIndexPath: indexPath];
    UITabBarController* tbc = [[SMTGAppDelegate sharedAppDelegate] tabBarController];
    UITabBarItem* tbi = [[tbc tabBar] selectedItem];
    NSString* tabItemTitle = [tbi title];
    
    if((!self.searching) && (indexPath.section == 0)){
        [self courseCreateModal];
        return;
    }
    
    // If we are searching and they selected a course then we want to close the search
    // for when they return to this view
    if(self.searching)
        [self doneSearching_Clicked: self];
    
    Course* courseObject = [[self class] courseObjectWithName: [[tVC textLabel] text] InContext: self.manObjCon];
    
    if([tabItemTitle isEqualToString: @"Scorecards"]){
        // Notify the New Round View Controller that a course was selected
        [self.courseSelectDelegate selectCourse: courseObject];
    }
    else if([tabItemTitle isEqualToString: @"Directory"]){
        // Display the course details
        CourseDetailViewController* cdvc = [[CourseDetailViewController alloc] initWithNibName:@"CourseDetailView" bundle:nil];
        
        [cdvc setCourseObj: courseObject];
        [self.navigationController pushViewController:cdvc animated:YES];
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
    }
    else if([tabItemTitle isEqualToString: @"Settings"]){
        // Notify the settings tab that we selected a course
        [self.courseSelectDelegate selectCourse: courseObject];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString* NewCourseCellIdentifier = @"NewCourseTableCell";
    static NSString *CellIdentifier = @"CourseTableCell";
    BOOL isActives = (self.appDel.curCourse) ? YES : NO;
    BOOL isFavs = ([favoriteNames count] == 0) ? NO : YES;
    BOOL isSpecial = NO;
    NSInteger section = indexPath.section;
    NSInteger newSection = indexPath.section;
    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString: @" ,"];
    
    // Always subtract one for the new course section
    newSection--;
    
    if(isActives)
        newSection--;
    if(isFavs)
        newSection--;
    
    UITableViewCell* cell = nil;
    if(section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier: NewCourseCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: NewCourseCellIdentifier];
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:    CellIdentifier];
        }
    }
   
    // Set up the cell...
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
    
    if(self.searching && ([self.searchB.text length] > 0)){
        isSpecial = YES;
        NSArray* compArr = [[self.nameSearch objectAtIndex:indexPath.row] componentsSeparatedByString:@";"];
        [lbl setText: [compArr objectAtIndex:0]];
        [lbl2 setText: [[compArr objectAtIndex:1] stringByTrimmingCharactersInSet: charSet]];
    }
    else if(indexPath.section == 0){
        [lbl setText: @"Add a new course"];
    }
    else if(isActives && (indexPath.section == 1)){
        [lbl setText: [self.appDel.curCourse coursename]];
        [lbl2 setText: [self.appDel.curCourse valueForKey: @"address"]];
    }
    else if(isFavs && (((section == 1) && (!isActives)) || ((section == 2) && (isActives)))){
        [lbl setText: [self.favoriteNames objectAtIndex: indexPath.row]];
        [lbl2 setText: [[self.favoriteLocs objectAtIndex: indexPath.row] 
                        stringByTrimmingCharactersInSet: charSet]];
    }
    else {
        NSArray* componentsArr = nil;
        NSString* firstCharStr = [self.arrayOfChars objectAtIndex: newSection];
        
        componentsArr = [[[self.coursesDict objectForKey: firstCharStr] objectAtIndex: indexPath.row ] componentsSeparatedByString: @";"];
        [lbl setText: [componentsArr objectAtIndex:0]];
        [lbl2 setText: [componentsArr objectAtIndex:1]];
    }

    if((!self.searching) && (indexPath.section == 0))
        [cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
    else
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if(searching)
        return nil;
    
    NSMutableArray *tempArray = [NSArray arrayWithObjects:@"{search}", @"A", @"B", @"C",
                                 @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                                 @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
                                 @"X", @"Y", @"Z", nil];
    
    return tempArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger retInt = 0;
    BOOL isActives = NO;
    BOOL isFavs = ([favoriteNames count] == 0) ? NO : YES;
        
    if(self.searching)
        return -1;

    if([title isEqualToString: @"{search}"]){
        [tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        return -1;
    }
    if(index > ([self.arrayOfChars count] - 1)){
        retInt = [self.arrayOfChars count] - 1;
        return retInt;
    }
    
    retInt = [self.arrayOfChars indexOfObject: title];
    
    if(isActives)
        retInt++;
    if(isFavs)
        retInt++;
   
    return retInt;
}

+ (Course*) courseObjectWithName:(NSString *)name InContext: (NSManagedObjectContext*) context
{
    Course* courseObj = nil;
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext: context];
    [fetchrequest setEntity: entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coursename == %@", name];
    [fetchrequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        courseObj = [array objectAtIndex:0];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching Course for course details");
    }
    
    
    return courseObj;
}

# pragma mark Search Bar methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    if([searchText length] > 0) {
        [UIView beginAnimations:nil context:NULL];
        self.blackView.alpha = 0.0;
        [UIView commitAnimations];
        self.tableV.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        [UIView beginAnimations:nil context:NULL];
        self.blackView.alpha = 0.7;
        [UIView commitAnimations];
        self.tableV.scrollEnabled = NO;
    }
    
    [self.tableV reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self searchTableView];
}

- (void) searchTableView {
    
    NSString *searchText = self.searchB.text;
    NSString* nameStr = nil;
    NSString* locStr = nil;
    NSArray* componentsArr = nil;
    NSInteger scopeIndex = [self.searchB selectedScopeButtonIndex];
    NSRange titleResultsRange = {NSNotFound, 0};
    NSMutableArray* tmpArr = [[NSMutableArray alloc] init];
    
    NSArray* tempArr = [self.coursesDict allValues];
    for(NSArray* tempArr2 in tempArr){

        for (NSString *sTemp in tempArr2)
        {
            componentsArr = [sTemp componentsSeparatedByString: @";"];
            nameStr = [componentsArr objectAtIndex: 0];
            locStr = [componentsArr objectAtIndex: 1];
            if(scopeIndex == kNAME_SCOPE_INDEX)
                titleResultsRange = [nameStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
            else if(scopeIndex == kLOC_SCOPE_INDEX)
                titleResultsRange = [locStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0){
                [tmpArr addObject: sTemp];
            }
        }
    }
    
    self.nameSearch = [tmpArr sortedArrayUsingSelector: @selector(compare:)];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar 
{
    self.searching = YES;
    
    [UIView beginAnimations:nil context:NULL];
    self.blackView.alpha = 0.7;
    [UIView commitAnimations];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self action:@selector(doneSearching_Clicked:)];
}

- (void) doneSearching_Clicked:(id)sender 
{
    self.searching = NO;
    
    self.searchB.text = @"";
    [self.searchB resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:nil context:NULL];
    self.blackView.alpha = 0.0;
    [UIView commitAnimations];
    
    self.tableV.scrollEnabled = YES;
    
    [self.tableV reloadData];
}

- (void) handleTapFrom: (UITapGestureRecognizer*) recognizer
{
    [self doneSearching_Clicked: self];
}

- (void) modalCancel:(id)sender
{
    [self.courseSelectDelegate selectCourse: nil];
}

- (void) courseCreateModal
{ 
    CustomCourseViewController* ccvc = [[CustomCourseViewController alloc] initWithNibName: @"CustomCourseView" bundle: nil];
    
    [self presentModalViewController: ccvc animated: YES];
}

@end
