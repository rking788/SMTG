//
//  DirectoryViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "DirectoryViewController.h"
#import "CourseSelectViewController.h"

@implementation DirectoryViewController
@synthesize navController;

@synthesize stateSet, countrySet, abbrsDict, stateArrDict;
@synthesize manObjCon;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize abbreviation dictionary
    NSString* stateAbbrsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stateabbrs.txt"];
    self.abbrsDict = [[NSDictionary alloc] initWithContentsOfFile: stateAbbrsPath];
    
    // Fill state and country sets
    [self fillStatesCountries];
    
    [self.navigationItem setTitle: @"State Select"];
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
    
    return ret;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setNavController:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.stateSet = nil;
    self.countrySet = nil;
    self.abbrsDict = nil;
    self.stateArrDict = nil;
}

- (void)dealloc
{
    [stateSet release];
    [countrySet release];
    [abbrsDict release];
    [stateArrDict release];
    [navController release];
    [super dealloc];
}

- (void) fillStatesCountries
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
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
    [manObjCon reset];

}

#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* countryStr = [[countrySet allObjects] objectAtIndex: section];
    return [[stateArrDict objectForKey: countryStr] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countrySet count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString* countryAbbr = [[countrySet allObjects] objectAtIndex: section];
    return [abbrsDict valueForKey: countryAbbr]; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];
    CourseSelectViewController* csvc = [[CourseSelectViewController alloc] initWithNibName:@"CourseSelectView" bundle:nil];
    csvc.manObjCon = self.manObjCon;
    NSString* countryStr = [[countrySet allObjects] objectAtIndex: indexPath.section];
    csvc.selectedState = [[stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
    
    [self.navController pushViewController:csvc animated:YES];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WeatherTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString* countryStr = [[countrySet allObjects] objectAtIndex: indexPath.section];
    NSString* stateStr = [[stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
    
    // Set up the cell...
    UILabel* lbl = [cell textLabel];
    //[lbl setText: [self.courseNames objectAtIndex:indexPath.row]];
    [lbl setText: [abbrsDict valueForKey: stateStr]];
    //UILabel* lbl2 = [cell detailTextLabel];
    //[lbl2 setText: [self.courseLocs objectAtIndex:indexPath.row]];
    //[lbl2 setText: @"Row2"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


@end
