//
//  NewRoundViewController.m
//  ECaddy
//
//  Created by RKing on 6/2/11.
//  Copyright 2011 RPKing. All rights reserved.
//

// TODOS: Need to figure out when to save the scorecards to the managedobjectcontext or when to store in a file.

#import "NewRoundViewController.h"
#import "DirectoryViewController.h"
#import "ECaddyAppDelegate.h"
#import "ScoreTrackerViewController.h"

@implementation NewRoundViewController

@synthesize actSheet;
@synthesize curCourse;

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
    [curCourse release];
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

    self.navigationItem.title = @"New Round";
    
    if(self.curCourse)
        NSLog(@"A course has already been selected");
    else
        [self loadDefaultCourse];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footView = [[[UIView alloc] init] autorelease];
    //create the button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //the button should be as big as a table view cell
    [button setFrame:CGRectMake(10, 3, 300, 44)];
    
    //set title, font size and font color
    [button setTitle:@"Begin Round" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor yellowColor]];

    //set action of the button
    [button addTarget:self action:@selector(beginRound) forControlEvents:UIControlEventTouchUpInside];
    
    //add the button to the view
    [footView addSubview:button];
    
    return footView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.curCourse = nil;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return numTableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get references to the text labels
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
   
    // Set the text of label 1
    if(indexPath.row == kCourseName){
        [lbl setText: @"Course"];
        if(self.curCourse)
            [lbl2 setText: [self.curCourse coursename]];
        else
            [lbl2 setText: @"Please Select a Course"];
    }
    else if(indexPath.row == kNumPlayers){
        [lbl setText: @"# of Players"];
        [lbl2 setText: @"1"];
    }
    else{
        [lbl setText: @"Something went wrong"];
    }
    
    // Set the accessory type to the little arrow
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == kCourseName){
        DirectoryViewController* dvc = [[DirectoryViewController alloc] initWithNibName:@"StateDirView" bundle:nil];
        UINavigationController* uinc = [[UINavigationController alloc] initWithRootViewController: dvc];
        
        // Need to provide the managed object context to the directory 
        // to find the available courses and stuff
        NSManagedObjectContext* manObjCon = [(ECaddyAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
     
        [dvc setManObjCon: manObjCon];
        [dvc setCourseSelectDelegate: self];
        [dvc setModal: YES];
        
        // Display the directory view controller with a UINavigationController as it's parent
        [uinc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        [self presentModalViewController:uinc animated:YES];
        [uinc release];
        
        // Don't think we need to release this anymore since we release the navcontroller
        // [dvc release];
    }
    else if(indexPath.row == kNumPlayers){
        [self showPickerView];
    }
}

- (void) showPickerView{
    self.actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; 
    
    UILabel* numPlayers = [[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:kNumPlayers inSection:0]] detailTextLabel];
    NSInteger nCur = [[numPlayers text] integerValue];
    nCur = nCur - 1;
    
    [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView* pickView = [[UIPickerView alloc] initWithFrame: pickerFrame];
    pickView.showsSelectionIndicator = YES;
    pickView.dataSource = self;
    pickView.delegate = self;
    pickView.tag = 150;
    [pickView selectRow: nCur inComponent: 0 animated: NO];
    [actSheet addSubview: pickView];
    
    // TODO: Do not hard code these size values if possible
    UISegmentedControl* closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Done", nil]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPickerView) forControlEvents:UIControlEventValueChanged];
    
    [self.actSheet addSubview:closeButton];
    [closeButton release];
    
    [self.actSheet showInView: self.view.window];
    
    [self.actSheet setBounds:CGRectMake(0, 0, 320, 485)];
    [self.actSheet autorelease];
}

- (void) dismissPickerView{
    [self.actSheet dismissWithClickedButtonIndex:0 animated:YES];
    UIPickerView* picker = (UIPickerView*) [self.actSheet viewWithTag:150];
    [self setActSheet:nil];
   
    NSInteger nSel = [picker selectedRowInComponent:0];
   
    UILabel* numPlayers = [[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:kNumPlayers inSection:0]] detailTextLabel];
    [numPlayers setText: [NSString stringWithFormat:@"%d", (nSel+1)]];
}

// UIPickerView delegate and datasource methods
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 5;
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d", (row + 1)];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}

#pragma mark CourseSelectProtocol implementation

- (void) selectCourse: (Course*) golfCourse
{   
    // Dismiss the modal course selection view controllers
    [self dismissModalViewControllerAnimated:YES];
    
    // If the course is nil then we probably clicked cancel or something
    if(!golfCourse)
        return;
    
    NSLog(@"Selected course: %@", [golfCourse coursename]);
    
    self.curCourse = golfCourse;
    
    NSIndexPath* indPath = [NSIndexPath indexPathForRow: kCourseName inSection: 0];
    UILabel* detailLbl = [[self.tableView cellForRowAtIndexPath: indPath] detailTextLabel];
    [detailLbl setText: [golfCourse coursename]];
}

- (void) beginRound
{
    if(!self.curCourse){
        NSLog(@"Error: the current course is nil when trying to begin a round.");
        return;
    }
    
    ECaddyAppDelegate* appDelegate = (ECaddyAppDelegate*) [[UIApplication sharedApplication] delegate];
    Scorecard* newScorecard = [appDelegate startNewRoundWithCourse: self.curCourse];

    // Add the scoretracker view controller to the navigation stack
    ScoreTrackerViewController* stvc = [[ScoreTrackerViewController alloc] initWithNibName: @"ScoreTrackerView" bundle:nil];
    
    [stvc setScorecard: newScorecard];
    
    [self.navigationController pushViewController:stvc animated:YES];
    [stvc release];
}

- (void) loadDefaultCourse
{
    
    // Should probably use the name of the default course here
    // Or at least the default state. A random golf course would be weird.
    NSManagedObjectContext* manObjCon = [(ECaddyAppDelegate*)
                                         [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext: manObjCon];
    [fetchrequest setEntity:entity];
    
    [fetchrequest setFetchLimit: 1];
    
    NSError *error = nil;
    NSArray *array = [manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
    
        self.curCourse = [array objectAtIndex: 0];
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
    [fetchrequest release];

}

@end
