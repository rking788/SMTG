//
//  DefaultUnitsViewController.m
//  SMTG
//
//  Created by Robert King on 9/18/11.
//  Copyright 2011 University of Maine. All rights reserved.
//

#import "DefaultUnitsViewController.h"

@implementation DefaultUnitsViewController

@synthesize tableV;
@synthesize navBar;
@synthesize unitsDict;
@synthesize defs;
@synthesize actSheet;
@synthesize pickerOptsArr;
@synthesize lastSelRow;

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
    
    // Set the background to clear to get rid of the little black edges around some cells
    [self.tableV setBackgroundColor: [UIColor clearColor]];
    
    // Add save and cancel buttons to the navigation bar
    [navBar.topItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action: @selector(cancel)]];
    
    [navBar.topItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target: self action: @selector(save)]];
    
    self.defs = [NSUserDefaults standardUserDefaults];
    
    [self initUnitsDict];
}

- (void)viewDidUnload
{
    [self setTableV:nil];
    [self setNavBar:nil];
    [self setUnitsDict: nil];
    [self setDefs: nil];
    [self setActSheet: nil];
    [self setPickerOptsArr: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) cancel
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void) save
{
    NSUInteger numRows = numRowTitles;
    
    // Save the default values in the NSUserDefauls object
    for(NSUInteger i = 0; i < numRows; i++){
        UITableViewCell* cell = [self.tableV cellForRowAtIndexPath: [NSIndexPath indexPathForRow: i inSection: 0]];
        [self.defs setObject: cell.detailTextLabel.text forKey: [self keyForIndex: i]];
    }
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void) initUnitsDict
{
    NSString* tmpDef = nil;
    NSString* tmpKey = nil;
    
    self.unitsDict = [[NSMutableDictionary alloc] initWithCapacity: numRowTitles];
    
    // Check for default temperature units
    tmpKey = [self keyForIndex: kTEMP];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Temperature", tmpDef, nil] forKey:tmpKey];
    }
    else{
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Temperature", @"Fahrenheit", nil] forKey: tmpKey];
    }
    
    // Check for default distance units
    tmpKey = [self keyForIndex: kDISTANCE];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Distance", tmpDef, nil] forKey:tmpKey];
    }
    else{
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Distance", @"Yards", nil] forKey: tmpKey];
    }
    
    // Visibility will not have a default value but we need this to make sure the detail text
    // label is left blank without crashing
    tmpKey = [self keyForIndex: kSPEED];
    tmpDef = [self.defs objectForKey: tmpKey];
    if(tmpDef){
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Speed", tmpDef, nil] forKey: tmpKey];
    }
    else{
        [self.unitsDict setObject: [[NSMutableArray alloc] initWithObjects: @"Speed", @"MPH", nil] forKey: tmpKey];
    }

}

- (NSString*) keyForIndex: (NSUInteger) index
{
    NSString* retStr = nil;
    
    switch (index){
        case kTEMP:
            retStr = @"tempunits";
            break;
        case kDISTANCE:
            retStr = @"distanceunits";
            break;
        case kSPEED:
            retStr = @"speedunits";
            break;
        default:
            break;
    }

    return retStr;
}


#pragma mark - Table View Data Source Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numRowTitles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* DefaultUnitsCellIdentifier = @"DefaultUnitsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: DefaultUnitsCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: DefaultUnitsCellIdentifier];
    }
    
    UILabel* lbl = [cell textLabel];
    UILabel* detLbl = [cell detailTextLabel];

    NSArray* dictObj;
    
    dictObj = [self.unitsDict objectForKey: [self keyForIndex:indexPath.row]];
    [lbl setText: [dictObj objectAtIndex: 0]];
    [detLbl setText: [dictObj objectAtIndex: 1]];
    
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


#pragma mark - Table View Delegate Methods
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Set the instructions to be the table view
    UILabel* instLbl = [[UILabel alloc] init];
    [instLbl setNumberOfLines: 0];
    [instLbl setText: @"Please select the default units that\nwill be used in the rest of the App."];
    [instLbl setTextColor: [UIColor whiteColor]];
    [instLbl setFont: [UIFont boldSystemFontOfSize: [UIFont systemFontSize]]];
    [instLbl setBackgroundColor: [UIColor clearColor]];
    [instLbl setTextAlignment: UITextAlignmentCenter];
    
    return instLbl;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 75;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
 
    if(!self.pickerOptsArr){
        self.pickerOptsArr = [[NSMutableArray alloc] init];
    }
    else if(self.pickerOptsArr.count > 0){
        [self.pickerOptsArr removeAllObjects];
    }
    
    switch (indexPath.row){
        case kTEMP:
            [self.pickerOptsArr addObject: @"Fahrenheit"];
            [self.pickerOptsArr addObject: @"Celsius"];
            break;
        case kDISTANCE:
            [self.pickerOptsArr addObject: @"Yards"];
            [self.pickerOptsArr addObject: @"Meters"];
            break;
        case kSPEED:
            [self.pickerOptsArr addObject: @"MPH"];
            [self.pickerOptsArr addObject: @"km/h"];
            break;
        default:
            break;
    }
    
    self.lastSelRow = indexPath.row;
    
    [self showPickerViewForIndexPath: indexPath];
}

- (void) showPickerViewForIndexPath: (NSIndexPath*) indPath{
    
    if(!self.actSheet){
        self.actSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; 
    }
   
    UITableViewCell* selCell = [self.tableV cellForRowAtIndexPath: [NSIndexPath indexPathForRow: indPath.row inSection:0]];
    NSLog(@"Selected Detail Text: %@", selCell.detailTextLabel.text);
    NSUInteger nCur = [self.pickerOptsArr indexOfObject: selCell.detailTextLabel.text];
    
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
    UISegmentedControl* doneButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Done", nil]];
    doneButton.momentary = YES;
    doneButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    doneButton.segmentedControlStyle = UISegmentedControlStyleBar;
    doneButton.tintColor = [UIColor blackColor];
    [doneButton addTarget:self action:@selector(dismissPickerView) forControlEvents:UIControlEventValueChanged];
    
    [self.actSheet addSubview: doneButton];
    
    [self.actSheet showInView: self.view.window];
    
    [self.actSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (void) dismissPickerView{
    [self.actSheet dismissWithClickedButtonIndex:0 animated:YES];
    UIPickerView* picker = (UIPickerView*) [self.actSheet viewWithTag:150];
    [self setActSheet:nil];
    
    NSInteger nSel = [picker selectedRowInComponent:0];
    
    UILabel* detailLbl = [[self.tableV cellForRowAtIndexPath: [NSIndexPath indexPathForRow: self.lastSelRow inSection:0]] detailTextLabel];
    [detailLbl setText: [self.pickerOptsArr objectAtIndex: nSel]];
}

// UIPickerView delegate and datasource methods
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - PickerView methods
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{    
    return 2;
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerOptsArr objectAtIndex: row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

@end
