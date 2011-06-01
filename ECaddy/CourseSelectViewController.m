//
//  CourseSelectViewController.m
//  ECaddy
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseSelectViewController.h"
#import "CourseDetailViewController.h"

@implementation CourseSelectViewController

@synthesize courseNames, courseLocs;
@synthesize nameSearch, locsSearch;
@synthesize selectedState;
@synthesize manObjCon;
@synthesize searchBar;
@synthesize tableV;
@synthesize blackView;
@synthesize navController;
@synthesize searching;

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
    [courseNames release];
    [courseLocs release];
    [navController release];
    [searchBar release];
    [tableV release];
    [blackView release];
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
    [self.navigationItem setTitle:@"Course Select"];
    
    self.courseNames = [[NSMutableArray alloc] init];
    self.courseLocs = [[NSMutableArray alloc] init];
    
    self.nameSearch = [[NSMutableArray alloc] init];
    self.locsSearch = [[NSMutableArray alloc] init];
    
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
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableV:nil];
    [self setBlackView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.courseLocs = nil;
    self.courseNames = nil;
    self.navController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSString* nameStr = nil;
        NSString* locStr = nil;
        
        for(NSManagedObject* manObj in array){
            
            nameStr = [manObj valueForKey: @"coursename"];
            locStr = [manObj valueForKey: @"address"];
            
            [self.courseNames addObject: nameStr];
            [self.courseLocs addObject: locStr];
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [sortDescript release];
    [sdArr release];
    [fetchrequest release];
   
    // Reset the managed object context (we don't need those objects anymore i dont think)
    [manObjCon reset];
}

#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    
    if(self.searching)
        num = [self.nameSearch count];
    else
        num = [self.courseNames count];
    
    return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];    
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coursename == %@", 
                              [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
    [fetchrequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        NSManagedObject* courseObj = [array objectAtIndex:0];
    
        CourseDetailViewController* cdvc = [[CourseDetailViewController alloc] initWithNibName:@"CourseDetailView" bundle:nil];
        
        [cdvc setCourseObj: courseObj];
        [self.navController pushViewController:cdvc animated:YES];
        [cdvc release];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching Course for course details");
    }
    
    [fetchrequest release];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"CourseTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
    
    if(self.searching){
        [lbl setText: [self.nameSearch objectAtIndex: indexPath.row]];
        [lbl2 setText: [self.locsSearch objectAtIndex: indexPath.row]];
    }
    else {
        [lbl setText: [self.courseNames objectAtIndex:indexPath.row]];
        [lbl2 setText: [self.courseLocs objectAtIndex:indexPath.row]];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

# pragma mark Search Bar methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [self.nameSearch removeAllObjects];
    
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
    NSUInteger i = 0;
    
    for (NSString *sTemp in self.courseNames)
    {
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0){
            [self.nameSearch addObject: [self.courseNames objectAtIndex:i]];
            [self.locsSearch addObject: [self.courseLocs objectAtIndex:i]];
        }
        
        i++;
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
    
    [UIView beginAnimations:nil context:NULL];
    self.blackView.alpha = 0.0;
    [UIView commitAnimations];

    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableV reloadData];
}

- (void) handleTapFrom: (UITapGestureRecognizer*) recognizer
{
    [self doneSearching_Clicked: self];
}

@end
