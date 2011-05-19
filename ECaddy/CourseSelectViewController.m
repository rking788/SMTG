//
//  CourseSelectViewController.m
//  ECaddy
//
//  Created by RKing on 5/18/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseSelectViewController.h"

@implementation CourseSelectViewController

@synthesize courseNames, courseLocs;
@synthesize selectedState;
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
    [courseNames release];
    [courseLocs release];
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
    
    // Fill the course names and locations
    [self fillNamesAndLocs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.courseLocs = nil;
    self.courseNames = nil;
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
    
}

#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.courseNames count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CourseTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    UILabel* lbl = [cell textLabel];
    [lbl setText: [self.courseNames objectAtIndex:indexPath.row]];
    
    UILabel* lbl2 = [cell detailTextLabel];
    [lbl2 setText: [self.courseLocs objectAtIndex:indexPath.row]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


@end
