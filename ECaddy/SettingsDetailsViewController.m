//
//  SettingsDetailsViewController.m
//  SMTG
//
//  Created by RKing on 6/20/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "SettingsDetailsViewController.h"
#import "SettingsViewController.h"
#import "SMTGAppDelegate.h"
#import "constants.h"

@implementation SettingsDetailsViewController

@synthesize delVC;
@synthesize delTV;
@synthesize detailType;
@synthesize manObjCon;
@synthesize curName;
@synthesize locObjs;
@synthesize sortedCountries;
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
    
    [navBar setTintColor: [UIColor colorWithRed:(0.0/255.0) green:(77.0/255.0) blue:(45.0/255.0) alpha:1.0]];
    
    // Add save and cancel buttons to the navigation bar
    [navBar.topItem setRightBarButtonItem: [[UIBarButtonItem alloc] 
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action: @selector(cancel)]];
    [navBar.topItem setLeftBarButtonItem: [[UIBarButtonItem alloc] 
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemSave target: self action: @selector(save)]];
    
    if(self.detailType == kNAME_EDIT){
        [self nameEditInit];
    }
    else if(self.detailType == kSTATE_VISIBILITY){
        // Initialize abbreviation dictionary
    
        UITableView* visTable = (UITableView*)[[self view] viewWithTag: kVISTABLE_TAG];
        [visTable setDelegate: self];
        [visTable setDataSource: self];
    
        [visTable setBackgroundColor: [UIColor clearColor]];
        
        NSString* stateAbbrsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: ABBRSFILENAME];
        self.abbrsDict = [[NSDictionary alloc] initWithContentsOfFile: stateAbbrsPath];
        self.manObjCon = [[SMTGAppDelegate sharedAppDelegate] managedObjectContext];
        
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
        
        NSSet* tmpCountrySet = [NSSet setWithArray: [array valueForKey: @"country"]];
        
        NSMutableArray* tmpCountryArr = [[NSMutableArray alloc] initWithCapacity: [tmpCountrySet count]];
        
        for(NSString* countryStr in tmpCountrySet){
            
            // Add the country long name to a sorted array used in the tableview
            [tmpCountryArr addObject: [[self.abbrsDict valueForKey: countryStr] objectAtIndex: 0]];
            
            // Filter the location objects to find only states in current country
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@", countryStr];  
            NSMutableArray* tmpArr = [NSMutableArray arrayWithArray: self.locObjs];
            [tmpArr filterUsingPredicate: predicate];
            
            // Sort the state names based on long names and not short names
            NSOrderedSet* sortedShortStates = [self sortShortStates: [tmpArr valueForKey: @"state"] InCountry: countryStr];
            
            [self.stateArrDict setObject: sortedShortStates forKey: countryStr];
        }
        
        self.sortedCountries = [self sortCountries: tmpCountryArr];
        
    }
    else {
        // Deal with error.
        NSLog(@"Error fetching lots");
    }
    
}

- (NSOrderedSet*) sortShortStates: (NSArray*) shortStateNames InCountry:(NSString *)shortCountry
{
    NSMutableArray* sortedShortStates = [NSMutableArray arrayWithCapacity: [shortStateNames count]];
    NSMutableArray* longNames = [NSMutableArray arrayWithCapacity: [shortStateNames count]];
    
    // Get an arrary of the long names for all of the states
    for (NSString* shortName in shortStateNames){
        NSString* longName = [[[self.abbrsDict valueForKey: shortCountry] objectAtIndex: 1] valueForKey: shortName];
        
        [longNames addObject: longName];
    }
    
    // Sort the array of long names
    NSArray* sortedLongStates = [longNames sortedArrayUsingSelector: @selector( caseInsensitiveCompare:)];
    
    // Create the array of sorted short state names
    for(NSString* longName in sortedLongStates){
        [sortedShortStates addObject: 
         [SettingsDetailsViewController stateSNInAbbrs: self.abbrsDict WithCSN: shortCountry WithSLN: longName]];
    }
    
    return [NSOrderedSet orderedSetWithArray: sortedShortStates];
}

- (NSArray*) sortCountries:(NSArray *)countryLongNames
{
    NSMutableArray* tmpShortCountryArr = [NSMutableArray arrayWithCapacity:
                                          [countryLongNames count]];
    NSArray* sortedLongNames = [countryLongNames sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    for (NSString* longCountry in sortedLongNames){
        NSString* shortName = [SettingsDetailsViewController countrySNInAbbrs: self.abbrsDict WithLN: longCountry];
        
        [tmpShortCountryArr addObject: shortName];
    }
    
    return [NSArray arrayWithArray: tmpShortCountryArr];
}

+ (NSString*) stateSNInAbbrs:(NSDictionary*) abbrs WithCSN: (NSString*) shortCN WithSLN: (NSString*) longSN
{
    NSDictionary* stateDict = [[abbrs valueForKey: shortCN] objectAtIndex: 1];
    return [[stateDict allKeysForObject: longSN] objectAtIndex: 0];
}                                      
                                      
+ (NSString*) countrySNInAbbrs:(NSDictionary*) abbrsDict WithLN:(NSString*) longName
{
    for (NSString* countryKey in [abbrsDict allKeys]){
        NSString* tmpStateLongName = [[abbrsDict valueForKey: countryKey] objectAtIndex: 0];
        if ([tmpStateLongName isEqualToString: longName])
            return countryKey;
    }
    
    return nil;
}
                               
#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retInt = -1;
    
    if(section == 0){
        retInt = 2;
    }
    else{
        NSString* countryStr = [self.sortedCountries objectAtIndex: (section - 1)];
        NSSet* stateSet = [self.stateArrDict objectForKey: countryStr];
   
        retInt = [stateSet count];
    }
    
    return retInt;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retInt = -1;
    
    retInt = [self.sortedCountries count] + 1;
    
    return retInt;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self tableView: tableView viewForHeaderInSection: section] == nil)
        return 0;
    else
        return 40;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lbl = [[UILabel alloc] init];
    
    if([self tableView: tableView titleForHeaderInSection: section] == nil)
        return nil;
    
    lbl.frame = CGRectMake( 15, 0, 300, 40);
    [lbl setText: [self tableView: tableView titleForHeaderInSection: section]];
    [lbl setTextColor: [UIColor whiteColor]];
    [lbl setBackgroundColor: [UIColor clearColor]];
    [lbl setFont: [UIFont fontWithName: @"Georgia Bold" size: 20.0]];
    lbl.shadowColor = [UIColor blackColor];
    lbl.shadowOffset = CGSizeMake(0.0, 1.0);
    
    UIView* view = [[UIView alloc] init];
    [view addSubview: (UIView*) lbl];
    
    return view;
}


- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString* retStr = nil;
    
    if(section == 0)
        return retStr;
    
    NSString* countryShortName = [self.sortedCountries objectAtIndex: (section - 1)];
    
    retStr = [[self.abbrsDict valueForKey: countryShortName] objectAtIndex: 0];
    
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:  CommandCellIdentifier];
        }
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:StateCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:  StateCellIdentifier];
        }
    }
    
    UILabel* lbl = [cell textLabel];
        
    // Set the accessory view to a switch if not in the first section
    if(indexPath.section == 0){
        if(indexPath.row == 0)
            [lbl setText: @"All On"];
        else if(indexPath.row == 1)
            [lbl setText: @"All Off"];
    }
    else{
        NSString* countryStr = [self.sortedCountries objectAtIndex: (indexPath.section - 1)];
        NSString* stateStr =  [[[self.stateArrDict objectForKey: countryStr] allObjects] objectAtIndex: indexPath.row];
        
        NSString* longState = [[[self.abbrsDict valueForKey: countryStr] objectAtIndex: 1] valueForKey: stateStr];
        
        if(longState)
            [lbl setText: longState];
        else
            [lbl setText: stateStr];
        
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
    }
    if(indexPath.section != 0)
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
   
    return cell;
}

- (void) switchToggled: (id) sender
{
    UISwitch* switchView = (UISwitch*) sender;
    NSString* stateName;
    NSString* stateAbbr;
    NSString* countryAbbr;
    NSInteger tagVal = [sender tag];
    NSInteger sect;
    NSInteger row;
    NSIndexPath* tabIndPath;
    UITableView* tableV = (UITableView*) [[self view] viewWithTag: kVISTABLE_TAG];
    
    sect = (tagVal - (kBASECELL_TAG + 1))/10;
    row = (tagVal - (kBASECELL_TAG + 1) - (sect * 10));
    
    tabIndPath = [NSIndexPath indexPathForRow: row inSection: sect];
    stateName = [[[tableV cellForRowAtIndexPath: tabIndPath] textLabel] text];
    countryAbbr = [self tableView: tableV titleForHeaderInSection: sect];

    stateAbbr = [[[[self.abbrsDict valueForKey: countryAbbr] objectAtIndex: 1] allKeysForObject: stateName] objectAtIndex: 0];
   
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

@end
