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
#import "Scorecard.h"
#import "Course.h"
#import "HeaderFooterView.h"

#define kOFFSET_FOR_KEYBOARD 125.0

#pragma mark - TODO Save the scorecard once it is created. If we view the scorecard and then the application terminates without going back to the new round view, then there is no active course the next time. ( thats wrong).

@implementation ScoreTrackerViewController

@synthesize appDel;
@synthesize scorecard;
@synthesize scoreHeaderView;
@synthesize scoreFooterView;
@synthesize titleTextView;
@synthesize favstarBtn;
@synthesize scorecardDict;
@synthesize scrollView;

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
    [appDel release];
    [scorecard release];
    [titleTextView release];
    [scoreHeaderView release];
    [scoreFooterView release];
    [scorecardDict release];
    [favstarBtn release];
    [scrollView release];
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
    
    self.appDel = [ECaddyAppDelegate sharedAppDelegate];
    
    if(self.scorecard){
        NSString* name;
        NSString* date;
        NSDateFormatter* dateF;
        
        name = [[self.scorecard course] coursename];
        dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat: @"MM/dd/yyyy hh:mm"];
        
        date = [dateF stringFromDate: [self.scorecard dateplayed]];
        [self.titleTextView setText: [NSString stringWithFormat: @"%@\n%@", name, date]];
 
        // Give the header and footer views a reference to us to alert us of changes
        [self.scoreHeaderView setScoreTracker: (ScoreTrackerViewController*) self];
        [self.scoreFooterView setScoreTracker: (ScoreTrackerViewController*) self];
        
        [dateF release];
        
        [self.favstarBtn setImage: [UIImage imageNamed: ([[self.scorecard.course favorite] boolValue] ? @"favstar_selected.png" : @"favstar_deselected.png")] forState: UIControlStateNormal];
        
        NSUInteger num = [[self.scorecard numplayers] unsignedIntegerValue];
        
        // Add the right number of names to the header of the table view
        [self.scoreHeaderView addHeaderColumnsForNumPlayers: num];
        [self.scoreHeaderView setHeaderOrFooter: @"Header"];
        [self.scoreFooterView addFooterColumnsForNumPlayers: num];
        [self.scoreFooterView setHeaderOrFooter: @"Footer"];
        
        // Get the player names from the header view
        [self.scorecard setPlayernames: [self.scoreHeaderView stringOfPlayers]];
        [self.scorecard setNumplayers: [NSNumber numberWithUnsignedInteger: num]];
        
        // Set the player names in the footer view to let it get the column numbers
        [self.scoreFooterView setPlayerNamesArr: [[self.scoreHeaderView stringOfPlayers] componentsSeparatedByString: @";"]];
        
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
}

- (void)viewDidUnload
{
    scrollView = nil;
    [super viewDidUnload];
    [self setAppDel: nil];
    [self setScorecard: nil];
    [self setTitleTextView:nil];
    [self setScoreHeaderView:nil];
    [self setScoreFooterView:nil];
    [self setFavstarBtn:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setScorecardDict: nil];
}

- (void) viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear: animated];
    // Load the players scores from the current scorecard object
    
    NSMutableDictionary* scoresdict = self.scorecard.scores;
    if(scoresdict)
        self.scorecardDict = (NSMutableDictionary*) self.scorecard.scores;
    
    // Update the totals in the footer view
    [self.scoreFooterView setTotalsWithScoreDict: self.scorecardDict];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    // Save the players scores to the sqlite store
    self.scorecard.scores = self.scorecardDict;

    [self.appDel saveContext];
    // Maybe Use a seperate thread to keep from being sluggish
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
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
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
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
    
    NSNumber* parnum = [self.scorecard.course.menpars objectAtIndex: indexPath.row]; 
    // TODO: Right now just using the mens pars maybe want to support womens' pars later
    if(!parnum)
        label.text = @"-";
    else{
        label.text = [NSString stringWithFormat: @"%@", [self.scorecard.course.menpars objectAtIndex: indexPath.row]];
    }
    
    UITextField* field;
    NSUInteger col = 0;
    for(UIView* view in cell.subviews){
        if(view.tag == HOLENUM_TAG || view.tag == PAR_TAG)
            continue;
        if(view.tag == 0)
            continue;

        field = (UITextField*) view;
        field.tag = [ScoreTrackerViewController tagFromRow: indexPath.row AndCol: col];
        field.text = [self stringForScoreWithRow:indexPath.row AndCol: [[[ScoreTrackerViewController rowAndColFromTag: field.tag] objectAtIndex: 1] unsignedIntegerValue]];
       
        // Only increment the column number if it is a textfield column
        col++;
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
    // If the names haven't changed then there is nothing else to do
    if([oldName isEqualToString: newName])
        return;
    
    // Update the names in the scorecard string
    [self.scorecard setPlayernames: [self.scoreHeaderView stringOfPlayers]];
    
    // Update the names in the footer view
    [self.scoreFooterView setPlayerNamesArr: [[self.scoreHeaderView stringOfPlayers] componentsSeparatedByString: @";"]];
    
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp: YES];
    }
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    [self setViewMovedUp: NO];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    NSNumber* newNumber = [f numberFromString: textField.text];
   
    NSArray* rowCol = [[ScoreTrackerViewController rowAndColFromTag: textField.tag] retain];
    NSUInteger row = [[rowCol objectAtIndex: 0] unsignedIntegerValue];
    NSUInteger col = [[rowCol objectAtIndex: 1] unsignedIntegerValue];
    
    NSString* playerName = [self.scoreHeaderView stringForNameInCol: col];
    
    if(newNumber){
        [[self.scorecardDict objectForKey: playerName] replaceObjectAtIndex: row withObject: newNumber];
    }
    else{
        [textField setText: @""];
        // This is the place holder if text is not a valid number
        [[self.scorecardDict objectForKey: playerName] replaceObjectAtIndex: row withObject: @"-"];
    }
    
    // Update the totals in the footer view
    [self.scoreFooterView setTotalsWithScoreDict: self.scorecardDict];
    
    [rowCol release];
    [f release];
}


#pragma  mark TODO: when the view is moved up, the scroll view top needs to be moved down a bit the holes from 2-18 are visible but hole #1 is not quite visible
- (void) setViewMovedUp: (BOOL) movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
        
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (IBAction)favstarPressed:(id)sender {
    BOOL fav = [[self.scorecard.course favorite] boolValue];
    
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstar_selected.png" : 
                                                     @"favstar_deselected.png")] forState: UIControlStateNormal];
    
    [self.scorecard.course setFavorite: [NSNumber numberWithBool: fav]];
    
    [self.appDel saveContext];
}
@end
