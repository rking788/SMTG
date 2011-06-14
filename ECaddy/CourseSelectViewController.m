//
//  CourseSelectViewController.m
//  ECaddy
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseSelectViewController.h"
#import "CourseDetailViewController.h"
#import "WeatherDetails.h"
#import "ECaddyAppDelegate.h"

@implementation CourseSelectViewController

@synthesize arrayOfChars, coursesDict;
@synthesize nameSearch, locsSearch;
@synthesize selectedState, longStateName;
@synthesize favoriteLocs, favoriteNames;
@synthesize manObjCon;
@synthesize searchBar;
@synthesize tableV;
@synthesize blackView;
@synthesize searching;
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

- (void)dealloc
{
    [arrayOfChars release];
    [coursesDict release];
    [searchBar release];
    [tableV release];
    [blackView release];
    [longStateName release];
    [favoriteNames release];
    [favoriteLocs release];
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
    
    // Set the title in the navigation bar
    if(self.selectedState)
        [self.navigationItem setTitle: self.longStateName];
    else
        [self.navigationItem setTitle:@"Course Select"];
    
    self.coursesDict = [[NSMutableDictionary alloc] initWithCapacity: 26];
    self.arrayOfChars = [[NSMutableArray alloc] initWithCapacity: 26];
    
    self.nameSearch = [[NSMutableArray alloc] init];
    self.locsSearch = [[NSMutableArray alloc] init];
    
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
    [recognizer release];
    
    self.searching = NO;

    // If the view controller is presented modally we want to provide a 
    // cancel button or done button in the navigation bar
    if([self isModal]){
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(modalCancel:)] autorelease];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.favoriteNames removeAllObjects];
    [self.favoriteLocs removeAllObjects];
    
    [self fillFavorites];
    [self.tableV reloadData];
}


- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableV:nil];
    [self setBlackView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setCoursesDict: nil];
    [self setArrayOfChars: nil];
    [self setLongStateName: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
                        [entityProps objectForKey: @"address"], [entityProps objectForKey: @"state"], nil];
    [fetchrequest setPropertiesToFetch: propArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* nameStr = nil;
        NSString* locStr = nil;
        
        for(NSManagedObject* manObj in array){
            
            nameStr = [manObj valueForKey: @"coursename"];
            locStr = [[[manObj valueForKey: @"address"] stringByAppendingString: @", "] stringByAppendingString:  [manObj valueForKey:@"state"]];
            
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

- (void) fillNamesAndLocs
{
    if(!self.selectedState){
        // Do something here to handle the case where an invalid state may 
        // have been selected (not sure why that would happen 
    }
        
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@", self.selectedState];
    [fetchrequest setPredicate:predicate];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"coursename" ascending:YES];
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
            locStr = [manObj valueForKey: @"address"];
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
                [tmpArr release]; tmpArr = nil;
            }
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching course names and locations");
    }
    
    [sortDescript release];
    [sdArr release];
    [fetchrequest release];
}

#pragma mark UITableViewDataSource Protocol Methods

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* retStr = nil;
    NSInteger newSection = section;
    BOOL isActives = NO;
    BOOL isFavs = ([favoriteNames count] == 0) ? NO : YES;
    
    if(self.searching){
        retStr = @"";
        return retStr;
    }
    
    if(isActives){
        newSection--;
        
        if(section == 0)
            retStr = @"Active Course";
    }
    else if(isFavs){
        newSection--;
        
        if((section == 0) && (!isActives))
            retStr = @"Favorites";
        else if((section == 1) && (isActives))
            retStr = @"Favorites";
    }
    
    if(retStr == nil){
         retStr = [self.arrayOfChars objectAtIndex: newSection];
    }
    
    return retStr;
}

#pragma mark - TODO Return the number of letters in the alphabet that are in the course names

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retInt = 1;
    BOOL isActives = NO;
    BOOL isFavs = ([favoriteNames count] == 0) ? NO : YES;
    
    if(self.searching)
        return 1;
    
    retInt = [self.arrayOfChars count];
    
    if(isActives)
        retInt++;
    else if(isFavs)
        retInt++;
    
    return retInt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = -1;
    BOOL isActives = NO;
    BOOL isFavs = ([self.favoriteNames count] == 0) ? NO : YES;
    NSInteger newSection = section;
    
    if(self.searching && ([self.searchBar.text length] > 0)){
        num = [self.nameSearch count];
        return num;
    }
    else if(isActives){
        newSection--;
        
        if(section == 0)
            num = 1;
    }
    else if(isFavs){
        newSection--;
        
        if((section == 0) && (!isActives))
            num = [favoriteNames count];
        else if((section == 1) && (isActives))
            num = [favoriteNames count];
    }
    
    if(num == -1)
        num = [[self.coursesDict objectForKey: [self.arrayOfChars objectAtIndex: newSection]] count];
    
    return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];
    
    UITableViewCell* tVC = [tableView cellForRowAtIndexPath: indexPath];
    UITabBarController* tbc = [(ECaddyAppDelegate*)[[UIApplication sharedApplication] delegate] tabBarController];
    UITabBarItem* tbi = [[tbc tabBar] selectedItem];
    NSString* tabItemTitle = [tbi title];
    
    Course* courseObject = [self courseObjectWithName: [[tVC textLabel] text]];
    
    // If we are searching and they selected a course then we want to close the search
    // for when they return to this view
    if(self.searching)
        [self doneSearching_Clicked: self];
    
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
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"CourseTableCell";
    BOOL isActives = NO;
    BOOL isFavs = ([favoriteNames count] == 0) ? NO : YES;
    BOOL isSpecial = NO;
    NSInteger section = indexPath.section;
    NSInteger newSection = indexPath.section;
    
    if(isActives)
        newSection--;
    if(isFavs)
        newSection--;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
    
    if(self.searching && ([self.searchBar.text length] > 0)){
        isSpecial = YES;
        [lbl setText: [self.nameSearch objectAtIndex: indexPath.row]];
        [lbl2 setText: [self.locsSearch objectAtIndex: indexPath.row]];
    }
    else if(isActives && (indexPath.section == 0)){
        [lbl setText: @"Active Course"];
        [lbl2 setText: @"Active Course Location"];
    }
    else if(isFavs && (((section == 0) && (!isActives)) || ((section == 1) && (isActives)))){
        [lbl setText: [self.favoriteNames objectAtIndex: indexPath.row]];
        [lbl2 setText: [self.favoriteLocs objectAtIndex: indexPath.row]];
    }
    else {
        NSArray* componentsArr = nil;
        NSString* firstCharStr = [self.arrayOfChars objectAtIndex: newSection];
        
        componentsArr = [[[self.coursesDict objectForKey: firstCharStr]objectAtIndex: indexPath.row ] componentsSeparatedByString: @";"];
        [lbl setText: [componentsArr objectAtIndex:0]];
        [lbl2 setText: [componentsArr objectAtIndex:1]];
    }
    
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
        retInt = 0;
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

- (Course*) courseObjectWithName:(NSString *)name
{
    Course* courseObj = nil;
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext: self.manObjCon];
    [fetchrequest setEntity: entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coursename == %@", name];
    [fetchrequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        courseObj = [array objectAtIndex:0];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching Course for course details");
    }
    
    [fetchrequest release];
    
    return courseObj;
}

# pragma mark Search Bar methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [self.nameSearch removeAllObjects];
    [self.locsSearch removeAllObjects];
    
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
    
    NSString *searchText = self.searchBar.text;
    NSString* nameStr = nil;
    NSString* locStr = nil;
    NSArray* componentsArr = nil;
    
    NSArray* tempArr = [self.coursesDict allValues];
    NSArray* temp = [self.coursesDict objectsForKeys: self.arrayOfChars notFoundMarker: @"new"];
    for(NSArray* tempArr2 in tempArr){

        for (NSString *sTemp in tempArr2)
        {
            componentsArr = [sTemp componentsSeparatedByString: @";"];
            nameStr = [componentsArr objectAtIndex: 0];
            locStr = [componentsArr objectAtIndex: 1];
            NSRange titleResultsRange = [nameStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
            if (titleResultsRange.length > 0){
                [self.nameSearch addObject: nameStr];
                [self.locsSearch addObject: locStr];
            }
        }
    }
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar 
{
    self.searching = YES;
    
    //self.blackView.alpha = 0.5;
    [UIView beginAnimations:nil context:NULL];
    self.blackView.alpha = 0.7;
    [UIView commitAnimations];
    //self.tableV.scrollEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self action:@selector(doneSearching_Clicked:)] autorelease];
}

- (void) doneSearching_Clicked:(id)sender 
{
    self.searching = NO;
    
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
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

@end
