//
//  SettingsViewController.m
//  ECaddy
//
//  Created by RKing on 6/16/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize defs;
@synthesize sectionTitles;
@synthesize userPrefsDict;
@synthesize coursePrefsDict;

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
    [defs release];
    [sectionTitles release];
    [userPrefsDict release];
    [coursePrefsDict release];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.defs = [NSUserDefaults standardUserDefaults];
    
    // Load the default section titles
    [self setupSectionTitles];

    [self setupUserPrefs];
    [self setupCoursePrefs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.sectionTitles = nil;
    self.userPrefsDict = nil;
    self.coursePrefsDict = nil;
    self.defs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // Return the number of sections.
    return numSectTitles;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex: section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger ret = -1;
    
    if(section == kUSER_SEC)
        ret = numUserPrefs;
    else if(section == kCOURSE_SEC)
        ret = numCoursePrefs;
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
    NSArray* dictObj;
    
    switch (indexPath.section) {
        case kUSER_SEC:
            dictObj = [self.userPrefsDict objectForKey: [self keyForIndex:indexPath.row InSection:kUSER_SEC]];
            [lbl setText: [dictObj objectAtIndex: kTITLE]];
            [lbl2 setText: [dictObj objectAtIndex: kDEF_VALUE]];
            break;
        case kCOURSE_SEC:
            dictObj = [self.coursePrefsDict objectForKey: [self keyForIndex: indexPath.row InSection:kCOURSE_SEC]];
            [lbl setText: [dictObj objectAtIndex: kTITLE]];
            [lbl2 setText: [dictObj objectAtIndex: kDEF_VALUE]];
            break;
        default:
            [lbl setText: @"Default"];
            [lbl2 setText: @"Default detail"];
            break;
    }
    
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle: UITableViewCellSelectionStyleBlue];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - Initialization methods

- (void) setupSectionTitles
{
    self.sectionTitles = [[NSMutableArray alloc] initWithCapacity: numSectTitles];
    
    [self.sectionTitles insertObject: @"User Information" atIndex: kUSER_SEC];
    [self.sectionTitles insertObject: @"Course Information" atIndex: kCOURSE_SEC];
}

- (void) setupUserPrefs
{
    NSString* tmpDef = nil;
    NSString* tmpKey = nil;
    
    self.userPrefsDict = [[NSMutableDictionary alloc] initWithCapacity: numUserPrefs];
    
    // Check for a default name
    tmpKey = [self keyForIndex: kNAME InSection: kUSER_SEC];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.userPrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Name", tmpDef, nil] forKey:tmpKey];
    }
    else{
        [self.userPrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Name", @"Name 1", nil] forKey: tmpKey];
    }
}

- (void) setupCoursePrefs
{
    NSString* tmpDef = nil;
    NSString* tmpKey = nil;
    
    self.coursePrefsDict = [[NSMutableDictionary alloc] initWithCapacity: numCoursePrefs];
    
    // Check for a default course name
    tmpKey = [self keyForIndex: kCOURSE InSection: kCOURSE_SEC];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.coursePrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Default Course", tmpDef, nil] forKey:tmpKey];
    }
    else{
        [self.coursePrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Default Course", @"N/A", nil] forKey: tmpKey];
    }
    
    // Check for a default state name
    tmpKey = [self keyForIndex: kSTATE InSection: kCOURSE_SEC];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.coursePrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Default State", tmpDef, nil] forKey:tmpKey];
    }
    else{
        [self.coursePrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Default State", @"N/A", nil] forKey: tmpKey];
    }
    
    // Visibility will not have a default value but we need this to make sure the detail text
    // label is left blank without crashing
    tmpKey = [self keyForIndex: kVISIBILITY InSection:kCOURSE_SEC];
    [self.coursePrefsDict setObject: [[NSMutableArray alloc] initWithObjects: @"State Visibility", @"", nil] forKey: tmpKey];
}

- (NSString*) keyForIndex: (NSInteger) index InSection: (NSInteger) sec
{
    NSString* retStr = nil;
    
    if(sec == kUSER_SEC){
        // User prefs
        switch (index){
            case kNAME:
                retStr = @"name";
                break;
            default:
                break;
        }
    }
    else{
        // Course Prefs
        switch (index) {
            case kCOURSE:
                retStr = @"course";
                break;
            case kSTATE:
                retStr = @"state";
                break;
            case kVISIBILITY:
                retStr = @"visibility";
                break;
            default:
                break;
        }
    }
    
    return retStr;
}

- (NSInteger) indexForKey: (NSString*) key 
{
    return -1;
}

@end
