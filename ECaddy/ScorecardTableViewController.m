//
//  ScorecardTableViewController.m
//  SMTG
//
//  Created by RKing on 6/28/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScorecardTableViewController.h"
#import "CoreData/CoreData.h"
#import "SMTGAppDelegate.h"
#import "Scorecard.h"
#import "ScoreTrackerViewController.h"

#pragma mark - TODO: If clearing all scorecards from a course, the section title stays behind which isn't really good.

@implementation ScorecardTableViewController

@synthesize manObjCon;
@synthesize courseNameDict;
@synthesize actives;
@synthesize actScorecard;
@synthesize selScorecard;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [courseNameDict release];
    [manObjCon release];
    [actScorecard release];
    [selScorecard release];
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
    
    // Set the managed object context
    self.manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
    
    // Allocate the dates dictionary (key => course name, value => dateplayed)
    self.courseNameDict = [[NSMutableDictionary alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Fill the list of scorecards
    [self fillScorecards];
    
    [self setActives: NO];
    self.actScorecard = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setCourseNameDict: nil];
    [self setManObjCon: nil];
    [self setActScorecard: nil];
    [self setSelScorecard: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.actScorecard = [[SMTGAppDelegate sharedAppDelegate] findActiveScorecard];
    if(self.actScorecard)
        self.actives = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of elements in the course name set
    NSInteger count = [[courseNameDict allKeys] count];
    
    if([self isActives])
        count++;
    
    return count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    NSArray* nameArr = [[self.courseNameDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if([self isActives] && (section == 0))
        title = @"Active Course";
    else if([self isActives])
        title = [nameArr objectAtIndex: (section - 1)];
    else
        title = [nameArr objectAtIndex: section];
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    // Return the number of rows in the section.
    NSString* nameStr;
    
    if([self isActives] && (section == 0))
        count = 1;
    else{
        nameStr = [self tableView: tableView titleForHeaderInSection: section];
        count = [[self.courseNameDict objectForKey: nameStr] count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScorecardTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    UILabel* mainLbl = [cell textLabel];
    UILabel* detailLbl = [cell detailTextLabel];
    NSDateFormatter* dateF;
    
    NSString* courseName = nil;
    NSDate* date = nil;
    
    if([self isActives] && (indexPath.section == 0)){
        courseName = self.actScorecard.course.coursename;
        date = self.actScorecard.dateplayed;
    }
    else{
        courseName = [self tableView: tableView titleForHeaderInSection: indexPath.section];
        NSMutableArray* tmpArr = [self.courseNameDict objectForKey: courseName];
        date = [tmpArr objectAtIndex: indexPath.row];
    }
    
    dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat: @"MM/dd/yyyy hh:mm"];
    
    [mainLbl setText: courseName]; 
    [detailLbl setText: [dateF stringFromDate: date]];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) fillScorecards
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    //[fetchrequest setResultType: NSDictionaryResultType];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"dateplayed" ascending:NO];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];

    if (array != nil) {
        
        for(Scorecard* manObj in array){
            NSString* name = [[manObj course] coursename];
            NSDate* date = [manObj dateplayed];
            NSMutableArray* tmpArr = [self.courseNameDict objectForKey: name];
            
            if(tmpArr){
                [tmpArr addObject: date];
            }
            else{
                tmpArr = [[NSMutableArray alloc] initWithObjects: date, nil];
                [self.courseNameDict setObject: tmpArr forKey: name]; 
            }
        }
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [sortDescript release];
    [sdArr release];
    //[propArr release];
    [fetchrequest release];   

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    // Push a score tracker view or something onto the navigation stack
    ScoreTrackerViewController* stvc = [[ScoreTrackerViewController alloc] initWithNibName: @"ScoreTrackerView" bundle:nil];
    
    NSString* nameStr;
    NSDate* date;
    
    if([self isActives] && (indexPath.section == 0)){
        nameStr = self.actScorecard.course.coursename;
        date = self.actScorecard.dateplayed;
    }
    else{
        nameStr = [self tableView: tableView titleForHeaderInSection: indexPath.section];
        date = [[self.courseNameDict objectForKey: nameStr] objectAtIndex: indexPath.row];
    }

    self.selScorecard = [self scorecardWithName: nameStr AndDate: date];
    [stvc setScorecard: self.selScorecard];
    
    [self.navigationController pushViewController:stvc animated:YES];
    
    [stvc release];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the object from the persistent store
    NSString* nameStr;
    NSDate* date;
   
    if([self isActives] && (indexPath.section == 0)){
        nameStr = self.actScorecard.course.coursename;
        date = self.actScorecard.dateplayed;
    }
    else{
        nameStr = [self tableView: tableView titleForHeaderInSection: indexPath.section];
        date = [[self.courseNameDict objectForKey: nameStr] objectAtIndex: indexPath.row];
    }
    
    self.selScorecard = [self scorecardWithName: nameStr AndDate: date];
    
    [self.manObjCon deleteObject: self.selScorecard];
    
    // Save the changes in the managed object context through the app delegate
    [[SMTGAppDelegate sharedAppDelegate] saveContext];
    
    // Remove the object from the array
    [[self.courseNameDict objectForKey: nameStr] removeObjectAtIndex: indexPath.row];
    
    // Remove the object from the table view
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (Scorecard*) scorecardWithName: (NSString*) name AndDate: (NSDate*) date
{
    Scorecard* retSC = nil;
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
  
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course.coursename == %@ AND dateplayed == %@", name, date];
    [fetchrequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    
    if (array != nil) {
        retSC = [array objectAtIndex: 0];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching scorecard");
    }
    
    //[propArr release];
    [fetchrequest release];   
    
    return retSC;
}

@end
