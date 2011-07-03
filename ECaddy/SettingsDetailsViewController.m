//
//  SettingsDetailsViewController.m
//  ECaddy
//
//  Created by RKing on 6/20/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "SettingsDetailsViewController.h"
#import "SettingsViewController.h"
#import "ECaddyAppDelegate.h"

@implementation SettingsDetailsViewController

@synthesize delVC;
@synthesize delTV;
@synthesize detailType;
@synthesize manObjCon;
@synthesize curName;
@synthesize locObjs;
@synthesize abbrsDict;
@synthesize stateArrDict;

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
    [super dealloc];
    [curName release];
    [locObjs release];
    [manObjCon release];
    [abbrsDict release];
    [stateArrDict release];
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

    UINavigationBar* navBar = (UINavigationBar*)[self.view viewWithTag: kNAVBAR_TAG];
    
    // Add save and cancel buttons to the navigation bar
    [navBar.topItem setRightBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action: @selector(cancel)] autorelease]];
    
    [navBar.topItem setLeftBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target: self action: @selector(save)] autorelease]];
    
    if(self.detailType == kNAME_EDIT){
        [self nameEditInit];
    }
    else if(self.detailType == kSTATE_VISIBILITY){
        // Initialize abbreviation dictionary
        
        UITableView* visTable = (UITableView*)[[self view] viewWithTag: kVISTABLE_TAG];
        [visTable setDelegate: self];
        [visTable setDataSource: self];
        
        NSString* stateAbbrsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stateabbrs.txt"];
        self.abbrsDict = [[NSDictionary alloc] initWithContentsOfFile: stateAbbrsPath];
        self.manObjCon = [[ECaddyAppDelegate sharedAppDelegate] managedObjectContext];
        
        self.locObjs = [[NSMutableArray alloc] init];
        self.stateArrDict = [[NSMutableDictionary alloc] init];
        [self fillStatesCountries];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.curName = nil;
    self.locObjs = nil;
    self.manObjCon = nil;
    self.abbrsDict = nil;
    self.stateArrDict = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Methods for initialization based on the setting selected
- (void) nameEditInit
{
    UITextField* nameEdit = (UITextField*) [[self view] viewWithTag: kNAMEEDIT_TAG];
    [nameEdit setReturnKeyType: UIReturnKeyDone];
    [nameEdit setDelegate: self];
    
    if(self.curName) 
        [nameEdit setText: self.curName];
}

# pragma mark UITextFieldDelegate Methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Methods for Navigation bar button actions
- (void) cancel
{
    [self.delVC cancelDetailsWithVC: self];
}

- (void) save
{
    if(self.detailType == kNAME_EDIT)
        self.curName = [(UITextField*)[[self view] viewWithTag: kNAMEEDIT_TAG] text];
    else if(self.detailType == kSTATE_VISIBILITY)
        [self.manObjCon save: nil];
    
    [self.delVC saveDetailsWithTableView: self.delTV WithVC: self];
}

- (void) fillStatesCountries
{
    NSFetchRequest* fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.manObjCon];
    [fetchrequest setEntity:entity];
    
    NSSortDescriptor* sortDescript = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:YES];
    NSArray* sdArr = [[NSArray alloc] initWithObjects: sortDescript, nil];
    [fetchrequest setSortDescriptors: sdArr];
    
    NSError *error = nil;
    NSArray *array = [self.manObjCon executeFetchRequest:fetchrequest error:&error];
    if (array != nil) {
        
        for(NSManagedObject* manObj in array){
            [self.locObjs addObject: manObj];
        }
        
        for(NSString* countryStr in [NSSet setWithArray: [array valueForKey: @"country"]]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@", countryStr];  
            NSMutableArray* tmpArr = [NSMutableArray arrayWithArray: self.locObjs];
            [tmpArr filterUsingPredicate:predicate];  
            [self.stateArrDict setObject: 
                [NSSet setWithArray: [tmpArr valueForKey:@"state"]] forKey: countryStr];
        }
        
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retInt = -1;
    
    if(section == 0){
        retInt = 2;
    }
    else{
        NSString* countryStr = [[self.stateArrDict allKeys] objectAtIndex: (section - 1)];
        NSSet* stateSet = [self.stateArrDict objectForKey: countryStr];
   
        retInt = [stateSet count];
    }
    
    return retInt;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retInt = -1;
    
    NSArray* countryArr = [self.stateArrDict allKeys];
    retInt = [countryArr count] + 1;
    
    return retInt;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString* retStr = nil;
    
    if(section == 0)
        return retStr;
    
    retStr = [[self.stateArrDict allKeys] objectAtIndex: (section - 1)];
    
    return retStr; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    if((indexPath.section == 0) && (indexPath.row == 0))
        [self allSwitchesOnOff: YES];
    else if((indexPath.section == 0) && (indexPath.row == 1))
        [self allSwitchesOnOff: NO];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* CommandCellIdentifier = @"CommandCell";
    static NSString* StateCellIdentifier = @"StateTableCell";
    UITableViewCell* cell = nil;
    
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:CommandCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:  CommandCellIdentifier] autorelease];
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:StateCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:  StateCellIdentifier] autorelease];
        }
    }
    
    UILabel* lbl = [cell textLabel];
        
    // Set the contents of the cell to be the state name with a little arrow indicating more details
       /* NSString* countryStr = [[countrySet allObjects] objectAtIndex: newSection];*/
      //  NSString* stateStr = [[stateArrDict valueForKey: countryStr] objectAtIndex: indexPath.row];
        
        //[lbl setText: [abbrsDict valueForKey: stateStr]];
        
    // Set the accessory view to a switch if not in the first section
    if(indexPath.section == 0){
        if(indexPath.row == 0)
            [lbl setText: @"All On"];
        else if(indexPath.row == 1)
            [lbl setText: @"All Off"];
    }
    else{
        NSString* countryStr = [[self.stateArrDict allKeys] objectAtIndex: (indexPath.section - 1)];
        NSString* stateStr =  [[[self.stateArrDict objectForKey: countryStr] allObjects] objectAtIndex: indexPath.row];
        
        [lbl setText: [self.abbrsDict valueForKey: stateStr]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@", stateStr];  
        NSMutableArray* tmpArr = [NSMutableArray arrayWithArray: self.locObjs];
        [tmpArr filterUsingPredicate:predicate];  
        
        BOOL isEnabled = [[[tmpArr objectAtIndex: 0] valueForKey: @"enabled"] boolValue];

        UISwitch* switchview = [[UISwitch alloc] initWithFrame: CGRectZero];
        NSInteger tagVal = (kBASECELL_TAG + 1) + (indexPath.section * 10) + indexPath.row;
        [switchview setTag: tagVal];
        [switchview setOn: isEnabled];
        [switchview addTarget: self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchview;
        [switchview release];
    }
    if(indexPath.section != 0)
        [cell setSelectionStyle: UITableViewCellEditingStyleNone];
   
    return cell;
}

- (void) switchToggled: (id) sender
{
    UISwitch* switchView = (UISwitch*) sender;
    NSString* stateName;
    NSString* stateAbbr;
    NSInteger tagVal = [sender tag];
    NSInteger sect;
    NSInteger row;
    NSIndexPath* tabIndPath;
    
    sect = (tagVal - (kBASECELL_TAG + 1))/10;
    row = (tagVal - (kBASECELL_TAG + 1) - (sect * 10));
    
    tabIndPath = [NSIndexPath indexPathForRow: row inSection: sect];
    stateName = [[[(UITableView*) [[self view] viewWithTag: kVISTABLE_TAG] cellForRowAtIndexPath:tabIndPath] textLabel] text];
    
    NSLog(@"Toggled State: %@, Abbr: %@, Value: %@", stateName, [[self.abbrsDict allKeysForObject:stateName] objectAtIndex:0], [NSNumber numberWithBool: [switchView isOn]]);

    stateAbbr = [[self.abbrsDict allKeysForObject: stateName] objectAtIndex: 0];
   
    [self toggleMOEWithStateAbbr: stateAbbr ToState: [switchView isOn]];
}

- (void) toggleMOEWithStateAbbr: (NSString*) abbr ToState: (BOOL) on
{
    for(NSManagedObject* managed in self.locObjs){
        if([[managed valueForKey: @"state"] isEqualToString: abbr])
            [managed setValue: [NSNumber numberWithBool: on] forKey: @"enabled"];
    }
}
- (void) allSwitchesOnOff: (BOOL) on
{
    UITableView* tv = (UITableView*) [[self view] viewWithTag: kVISTABLE_TAG];
    
    for (NSManagedObject* managed in self.locObjs) {
        [managed setValue: [NSNumber numberWithBool: on] forKey: @"enabled"];
    }

    [tv reloadData];
}

#pragma mark - TODO IMPLEMENT THESE FUNCTIONS
- (NSString*) stateNameWithAbbr: (NSString*) abbr
{

    return nil;
}

- (NSString*) stateAbbrWithName: (NSString*) name
{
    
    return nil;
}

@end
