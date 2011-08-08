//
//  SettingsViewController.m
//  SMTG
//
//  Created by RKing on 6/16/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "SettingsViewController.h"
#import "SMTGAppDelegate.h"
#import "SettingsDetailsViewController.h"
#import "DirectoryViewController.h"

static NSString* CONTACTEMAIL = @"admin@mainelyapps.com";
static NSString* CONTACTSITE = @"http://mainelyapps.com";

@implementation SettingsViewController

@synthesize tableV;
@synthesize defs;
@synthesize sectionTitles;
@synthesize userPrefsDict;
@synthesize coursePrefsDict;
@synthesize contactPrefsArr;
@synthesize selectedSettingsDetail;

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
    [contactPrefsArr release];
    [tableV release];
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
    
    self.tableV.backgroundColor = [UIColor clearColor];
    
    self.defs = [NSUserDefaults standardUserDefaults];
    
    // Load the default section titles
    [self setupSectionTitles];

    [self setupUserPrefs];
    [self setupCoursePrefs];
    [self setupContactPrefs];
}

- (void)viewDidUnload
{
    [self setTableV:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.sectionTitles = nil;
    self.userPrefsDict = nil;
    self.coursePrefsDict = nil;
    self.contactPrefsArr = nil;
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numSectTitles;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    
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
    else if(section == kCONTACT_SEC)
        ret = numContactPrefs;
    
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
        case kCONTACT_SEC:
            [lbl setText: [self.contactPrefsArr objectAtIndex: indexPath.row]];
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
    
    // Default name setting selected
    if(indexPath.section == kUSER_SEC && indexPath.row == kNAME){
        SettingsDetailsViewController* sdvc = [[SettingsDetailsViewController alloc] initWithNibName:@"NameEditView" bundle:nil];

        [sdvc setDelVC: self];
        [sdvc setDelTV: tableView];
        [sdvc setDetailType: kNAME_EDIT];
        [sdvc setCurName: [[[tableView cellForRowAtIndexPath: indexPath] detailTextLabel] text]];
        
        [self presentModalViewController: sdvc animated: YES];
        [sdvc release];
        [self setSelectedSettingsDetail: kNAME_EDIT];
    }
    else if(indexPath.section == kCONTACT_SEC){
        NSString* titleStr = nil;
        NSString* buttonTitleStr = nil;
        
        if(indexPath.row == kEMAIL){
            titleStr = CONTACTEMAIL;
            buttonTitleStr = @"Open Mail";
        }
        else if(indexPath.row == kWEBSITE){
            titleStr = CONTACTSITE;
            buttonTitleStr = @"Open Browser";
        }
        
        UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle: titleStr delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil otherButtonTitles: buttonTitleStr, nil];
        actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actSheet showFromTabBar: self.tabBarController.tabBar];
        [actSheet release];
    }
    else if((indexPath.section == kCOURSE_SEC) && (indexPath.row == kCOURSE)){
        DirectoryViewController* dvc = [[DirectoryViewController alloc] initWithNibName:@"StateDirView" bundle:nil];
        UINavigationController* uinc = [[UINavigationController alloc] initWithRootViewController: dvc];
        
        [uinc.navigationBar setTintColor: [UIColor colorWithRed:(0.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0]];
        
        // Need to provide the managed object context to the directory 
        // to find the available courses and stuff
        NSManagedObjectContext* manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
        
        [dvc setManObjCon: manObjCon];
        [dvc setCourseSelectDelegate: self];
        [dvc setModal: YES];
        [dvc setSettingsDetailType: kCOURSE_EDIT];
        
        // Display the directory view controller with a UINavigationController as it's parent
        [uinc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        [self presentModalViewController:uinc animated:YES];
        [uinc release];
        
        [self setSelectedSettingsDetail: kCOURSE_EDIT];
    }
    else if((indexPath.section == kCOURSE_SEC) && (indexPath.row == kSTATE)){
        DirectoryViewController* dvc = [[DirectoryViewController alloc] initWithNibName:@"StateDirView" bundle:nil];
        UINavigationController* uinc = [[UINavigationController alloc] initWithRootViewController: dvc];
        
        [uinc.navigationBar setTintColor: [UIColor colorWithRed:(0.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0]];
        
        // Need to provide the managed object context to the directory 
        // to find the available courses and stuff
        NSManagedObjectContext* manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
        
        [dvc setManObjCon: manObjCon];
        [dvc setCourseSelectDelegate: self];
        [dvc setModal: YES];
        [dvc setSettingsDetailType: kSTATE_EDIT];
        
        // Display the directory view controller with a UINavigationController as it's parent
        [uinc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        [self presentModalViewController:uinc animated:YES];
        [uinc release];
        
        [self setSelectedSettingsDetail: kSTATE_EDIT];
    }
    else if((indexPath.section == kCOURSE_SEC) && (indexPath.row == kVISIBILITY)){
        SettingsDetailsViewController* sdvc = [[SettingsDetailsViewController alloc] initWithNibName:@"HideStateView" bundle:nil];
        
        [sdvc setDelVC: self];
        [sdvc setDetailType: kSTATE_VISIBILITY];
        [self presentModalViewController: sdvc animated: YES];
        [sdvc release];
        [self setSelectedSettingsDetail: kSTATE_VISIBILITY];
    }
}

#pragma mark - Initialization methods

- (void) setupSectionTitles
{
    self.sectionTitles = [[NSMutableArray alloc] initWithCapacity: numSectTitles];
    
    [self.sectionTitles insertObject: @"User Information" atIndex: kUSER_SEC];
    [self.sectionTitles insertObject: @"Course Information" atIndex: kCOURSE_SEC];
    [self.sectionTitles insertObject: @"Contact" atIndex: kCONTACT_SEC];
}

- (void) setupContactPrefs
{
    self.contactPrefsArr = [[NSMutableArray alloc] initWithCapacity: numContactPrefs];
   
    [self.contactPrefsArr insertObject: @"Email" atIndex: kEMAIL];
    [self.contactPrefsArr insertObject: @"Website" atIndex: kWEBSITE];
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
                retStr = @"coursename";
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

#pragma mark - Settings Details Methods
- (void) saveDetailsWithTableView:(UITableView*) tv WithVC: (SettingsDetailsViewController*) vc
{
    if(self.selectedSettingsDetail == kNAME_EDIT){
        NSMutableArray* tmpArr = [self.userPrefsDict objectForKey:[self keyForIndex:kNAME InSection:kUSER_SEC]];

        [tmpArr replaceObjectAtIndex: kDEF_VALUE withObject: vc.curName];
        [self.defs setObject: vc.curName forKey:@"name"];
        [self.defs synchronize];
    }
    
    [tv reloadData];
    [vc dismissModalViewControllerAnimated: YES];
}

- (void) saveState: (NSString*) state
{
    NSMutableArray* tmpArr = [self.coursePrefsDict objectForKey:[self keyForIndex:kSTATE InSection:kCOURSE_SEC]];
    
    [tmpArr replaceObjectAtIndex: kDEF_VALUE withObject: state];
    [self.defs setObject: state forKey:@"state"];
    [self.defs synchronize];

    [self.tableV reloadData];
    [self dismissModalViewControllerAnimated: YES];
}

- (void) cancelDetailsWithVC: (UIViewController*) vc
{
    [vc dismissModalViewControllerAnimated: YES];
}

#pragma mark - CourseSelectDelegate methods
- (void) selectCourse: (Course*) golfCourse
{
    // They clicked cancel
    if(!golfCourse){
        [self dismissModalViewControllerAnimated: YES];
        return;
    }
    
    if(self.selectedSettingsDetail == kCOURSE_EDIT){
        NSMutableArray* tmpArr = [self.coursePrefsDict objectForKey:[self keyForIndex:kCOURSE InSection: kCOURSE_SEC]];
        
        [tmpArr replaceObjectAtIndex: kDEF_VALUE withObject: [golfCourse coursename]];
        [self.defs setObject: [golfCourse coursename] forKey:@"coursename"];
    }
    else if(self.selectedSettingsDetail == kSTATE_EDIT){
        NSMutableArray* tmpArr = [self.coursePrefsDict objectForKey:[self keyForIndex:kSTATE InSection: kCOURSE_SEC]];
        
        [tmpArr replaceObjectAtIndex: kDEF_VALUE withObject: [golfCourse valueForKey:@"state"]];
        [self.defs setObject: [golfCourse valueForKey:@"state"] forKey:@"state"];
    }
    
    [self.tableV reloadData];
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - UIActionSheetDelegate Method
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* urlStr = nil;
    NSString* btnTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    
    if( [btnTitle isEqualToString: @"Open Mail"]){
        NSString* subjectStr = @"Regarding%20Show%20Me%20the%20Green";
        urlStr = [NSString stringWithFormat: @"mailto:%@?subject=%@", CONTACTEMAIL, subjectStr];
    }
    else if([btnTitle isEqualToString: @"Open Browser"]){
        urlStr = CONTACTSITE;
    }
    
    NSURL* url = [NSURL URLWithString: urlStr];
    [[UIApplication sharedApplication] openURL: url];
}

@end
