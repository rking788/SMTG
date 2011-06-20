//
//  ScoreTrackerViewController.m
//  ECaddy
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScoreTrackerViewController.h"
#import "ScorecardTableCell.h"
#import "ECaddyAppDelegate.h"


@implementation ScoreTrackerViewController

@synthesize scoreHeaderView;
@synthesize scoreFooterView;
@synthesize titleTextView;
@synthesize favstarBtn;
@synthesize scorecardDict;
@synthesize scorecard;

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
    [scorecard release];
    [titleTextView release];
    [scoreHeaderView release];
    [scoreFooterView release];
    [scorecardDict release];
    [favstarBtn release];
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
    
    if(self.scorecard){
        NSString* name;
        NSString* date;
        NSDateFormatter* dateF;
        
        name = [[self.scorecard course] coursename];
        dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat: @"MM/dd/yyyy hh:mm"];
        
        date = [dateF stringFromDate: [self.scorecard dateplayed]];
        [self.titleTextView setText: [NSString stringWithFormat: @"%@\n%@", name, date]];
 
        // Give the header view a reference to us to alert us of changes
        [self.scoreHeaderView setScoreTracker: (ScoreTrackerViewController*) self];
        
        [dateF release];
        
        [self.favstarBtn setImage: [UIImage imageNamed: ([[self.scorecard.course favorite] boolValue] ? @"favstar_selected.png" : 
                                                         @"favstar_deselected.png")] forState: UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [self setTitleTextView:nil];
    [self setScoreHeaderView:nil];
    [self setScoreFooterView:nil];
    [self setFavstarBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scorecard = nil;
    [self setScorecardDict: nil];
}

- (void) viewWillAppear:(BOOL)animated
{   
    NSUInteger num = [[self.scorecard numplayers] unsignedIntegerValue];
    // Add the right number of names to the header of the table view
    [self.scoreHeaderView addColumnsForNumPlayers: num];
    
    // Get the player names from the header view
    [self.scorecard setPlayernames: [self.scoreHeaderView stringOfPlayers]];
    [self.scorecard setNumplayers: [NSNumber numberWithUnsignedInteger: num]];
    
    // Initialize the dictionary holding the following data:
    //    keys    = NString Player Names
    //    values  = NSMutableArray of scores
    self.scorecardDict = [[NSMutableDictionary alloc] initWithCapacity: num];
    
    NSMutableArray* dictArr = nil;
    // Initialize the values in the scorecard dictionary
    for(NSString* str in [[self.scorecard playernames] componentsSeparatedByString: @";"]){
    
        // TODO: This 18 should probably be changed to the number of holes on the course
        dictArr = [[NSMutableArray alloc] initWithObjects:@"-", @"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-", nil];
        [self.scorecardDict setObject: dictArr forKey: str];
        [dictArr release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 18;
    
    return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CourseTableCell";
    static const NSUInteger constColWidth = 45;
    UILabel* label;
    
    ScorecardTableCell *cell = (ScorecardTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[ScorecardTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        
        label = [[[UILabel alloc] initWithFrame: CGRectMake(0.0, 0.0, constColWidth-1, tableView.rowHeight)] autorelease];
        
        [cell addColumn: 44];
        label.tag = HOLENUM_TAG;
        label.font = [UIFont systemFontOfSize: 17.0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview: label];
    
        label = [[[UILabel alloc] initWithFrame: CGRectMake(constColWidth, 0, constColWidth, tableView.rowHeight)] autorelease];
        
        [cell addColumn: 90];
        label.tag = PAR_TAG;
        label.font = [UIFont systemFontOfSize: 17.0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview: label];
        
        UITextField* scoreTF;
        CGRect scoreRect;
        NSUInteger numPlayers = [[self.scorecard numplayers] unsignedIntegerValue];
        CGFloat varColWidth = (CGFloat)((cell.bounds.size.width - (2 * constColWidth))/ numPlayers);
        CGFloat varColOffset;
        
        for(int i = 0; i < numPlayers; i++){
            varColOffset = ((constColWidth) * 2);;
            
            [cell addColumn: varColOffset + (varColWidth * i)];
            
            // Setup the TextField with a calculated CGRect
            scoreRect = CGRectMake((varColOffset + (i * varColWidth)), 0, varColWidth, cell.bounds.size.height);
            scoreTF = [[UITextField alloc] initWithFrame: scoreRect];
            
            [scoreTF setPlaceholder: [NSString stringWithFormat: @"-", (i + 1)]];
            [scoreTF setTextAlignment: UITextAlignmentCenter];
            [scoreTF setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
            [scoreTF setAdjustsFontSizeToFitWidth: YES];
            [scoreTF setMinimumFontSize: 8];
            [scoreTF setFont: [UIFont fontWithName: @"Helvetica" size: 17.0]];
            [scoreTF setDelegate: self];
            [scoreTF setKeyboardType: UIKeyboardTypeNumbersAndPunctuation];
            [scoreTF setReturnKeyType: UIReturnKeyDone];
            [scoreTF setTag: [ScoreTrackerViewController tagFromRow: indexPath.row AndCol: i]];
            
            [cell addSubview: scoreTF];
            
            [scoreTF release];
        }
    }
    
    label = (UILabel*) [cell viewWithTag: HOLENUM_TAG];
    label.text = [NSString stringWithFormat: @"%d", indexPath.row + 1];
    
    label = (UILabel*) [cell viewWithTag: PAR_TAG];
    label.text = [NSString stringWithFormat: @"%d", 3];
    
    UITextField* field;
    for(UIView* view in cell.subviews){
        if(view.tag == HOLENUM_TAG || view.tag == PAR_TAG)
            continue;
        if(view.tag == 0)
            continue;
        
        field = (UITextField*) view;
        field.text = [self stringForScoreWithRow:indexPath.row AndCol: [[[ScoreTrackerViewController rowAndColFromTag: field.tag] objectAtIndex: 1] unsignedIntegerValue]];
    }
  //  UITextField* field = (UITextField*) [cell viewWithTag: PAR_TAG + 2];
  //  field.text = [NSString stringWithFormat: @"%d", (field.tag - PAR_TAG)];
    
    return cell;
}

+ (NSUInteger) tagFromRow:(NSUInteger)row AndCol:(NSUInteger)col
{
    return (NSUInteger) ((PAR_TAG + 1) + (10 * row) + col);
}

+ (NSArray*) rowAndColFromTag:(NSUInteger)tag
{
    NSNumber* row,* col;
    
    row = [NSNumber numberWithUnsignedInteger: ((tag - (PAR_TAG + 1))/ 10)];
    col = [NSNumber numberWithUnsignedInteger: (tag - (PAR_TAG + 1) - ([row unsignedIntegerValue] * 10))];
    
    return [NSArray arrayWithObjects: row, col, nil];
}

- (void) nameChangedFrom: (NSString*) oldName To: (NSString*) newName
{
    // Update the names in the scorecard string
    [self.scorecard setPlayernames: [self.scoreHeaderView stringOfPlayers]];
    
    // Update the keys in the scorecardDict
    NSMutableArray* copyValue = [self.scorecardDict objectForKey: oldName];
    [self.scorecardDict setObject:copyValue forKey:newName];
    [self.scorecardDict removeObjectForKey: oldName];
    
}

- (NSString*) stringForScoreWithRow: (NSUInteger) row AndCol: (NSUInteger) col
{
    NSString* retStr = @"";
    NSString* nameStr;
    id object;
    nameStr = [self.scoreHeaderView stringForNameInCol: col];
    
    // This check is here because it will crash if the object in the dictionary is @"-"
    object = [[self.scorecardDict objectForKey: nameStr] objectAtIndex: row];
    if([object isKindOfClass: [NSNumber class]])
        retStr = [(NSNumber*) object stringValue];
    
    return retStr;
}

# pragma mark UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    NSNumber * newNumber = [f numberFromString: textField.text];
    
    if(!newNumber){
   	     [textField setText: @""];
        return;
    }
   
    NSArray* rowCol = [[ScoreTrackerViewController rowAndColFromTag: textField.tag] retain];
    NSUInteger row = [[rowCol objectAtIndex: 0] unsignedIntegerValue];
    NSUInteger col = [[rowCol objectAtIndex: 1] unsignedIntegerValue];
    
    NSString* playerName = [self.scoreHeaderView stringForNameInCol: col];
    
    [[self.scorecardDict objectForKey: playerName] replaceObjectAtIndex: row withObject: newNumber];
    
    [rowCol release];
    [f release];
}

# pragma mark - TODO Probably need to save the managed object context here 

- (IBAction)favstarPressed:(id)sender {
    ECaddyAppDelegate* appDel = [ECaddyAppDelegate sharedAppDelegate];
    
    BOOL fav = [[self.scorecard.course favorite] boolValue];
    
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstar_selected.png" : 
                                                     @"favstar_deselected.png")] forState: UIControlStateNormal];
    
    [self.scorecard.course setFavorite: [NSNumber numberWithBool: fav]];
    
    [appDel saveContext];
}
@end
