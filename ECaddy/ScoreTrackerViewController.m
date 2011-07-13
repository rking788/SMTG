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
#import "FBConnect.h"

// Facebook app ID constant string
static NSString* kAppId = @"142876775786876";

#pragma mark - TODO Save the scorecard once it is created. If we view the scorecard and then the application terminates without going back to the new round view, then there is no active course the next time. ( thats wrong).

@implementation ScoreTrackerViewController

@synthesize appDel;
@synthesize scorecard;
@synthesize scoreHeaderView;
@synthesize scoreFooterView;
@synthesize titleTextView;
@synthesize favstarBtn;
@synthesize scorecardDict;
@synthesize tableV;
@synthesize activeField;
@synthesize FB = _FB;
@synthesize FBpermissions;
@synthesize FBLoggedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.FBpermissions = [NSArray arrayWithObjects: @"publish_stream", @"offline_access", nil];
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
    [tableV release];
    [FBpermissions release];
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
    
    self.appDel = [ECaddyAppDelegate sharedAppDelegate];
    
    // Register listeners for keyboard notifications
    [self registerForKeyboardNotifications];
    
    // TODO: Implement this to provide actions like posting to facebook and finishing a round
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                               target:self action:@selector(FBButtonClicked:)] autorelease];
    
    // Create the Facebook instance
    self.FBLoggedIn = NO;
    _FB = [[Facebook alloc] initWithAppId:kAppId];
    [[ECaddyAppDelegate sharedAppDelegate] setFBInstance: self.FB];
    
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
    [self setTableV:nil];
    [super viewDidUnload];
    [self setAppDel: nil];
    [self setScorecard: nil];
    [self setTitleTextView:nil];
    [self setScoreHeaderView:nil];
    [self setScoreFooterView:nil];
    [self setFavstarBtn:nil];
    [self setFBpermissions: nil];
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
    self.activeField = textField;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    self.activeField = textField;
    
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

- (IBAction)favstarPressed:(id)sender {
    BOOL fav = [[self.scorecard.course favorite] boolValue];
    
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstar_selected.png" : 
                                                     @"favstar_deselected.png")] forState: UIControlStateNormal];
    
    [self.scorecard.course setFavorite: [NSNumber numberWithBool: fav]];
    
    [self.appDel saveContext];
}


# pragma mark - Keyboard related methods, to move view so nothing is hidden behind the keyboard
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // Move up the main view to hide the header
    [self setViewMovedUp: YES];
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableV.contentInset = contentInsets;
    self.tableV.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [self.tableV setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // Move the main view back down to reveal the header
    [self setViewMovedUp: NO];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableV.contentInset = contentInsets;
    self.tableV.scrollIndicatorInsets = contentInsets;
}

# pragma mark - TODO: CRITICAL This still does not scroll up correctly

- (void) setViewMovedUp: (BOOL) movedUp
{
    CGFloat table_y_offset = self.scoreHeaderView.frame.origin.y;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rect = self.view.frame;
    if (movedUp){
        rect.origin.y -= table_y_offset;
        rect.size.height += table_y_offset;
    }
    else{
        rect.origin.y += table_y_offset;
        rect.size.height -= table_y_offset;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - Facebook Methods

- (void) login
{
    [self.FB authorize: self.FBpermissions delegate: self];
}

- (void) logout
{
    [self.FB logout: self];
}

- (void) FBButtonClicked: (id) sender
{
    if(![self isFBLoggedIn]){
        [self login];
        self.FBLoggedIn = YES;
    }
    else{
        [self uploadPhoto];
        //[self logout];
    }
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    self.FBLoggedIn = YES;
    [self uploadPhoto];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Failed logging in to Facebook");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    self.FBLoggedIn = NO;
}

/**
 * Open an inline dialog that allows the logged in user to publish a story to his or
 * her wall.
 */
- (void)publishStream
{
    
    SBJSON *jsonWriter = [[SBJSON new] autorelease];
    
    NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"Always Running",@"text",@"http://itsti.me/",@"href", nil], nil];
    
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"a long run", @"name",
                                @"The Facebook Running app", @"caption",
                                @"it is fun", @"description",
                                @"http://itsti.me/", @"href", nil];
    NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Share on Facebook",  @"user_message_prompt",
                                   actionLinksStr, @"action_links",
                                   attachmentStr, @"attachment",
                                   nil];
    
    
    [self.FB dialog:@"feed"
            andParams:params
          andDelegate:self];
}

/**
 * Upload a photo.
 */
- (void)uploadPhoto
{
    NSString *path = @"http://king.eece.maine.edu/fenway.png";
    NSURL *url = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img  = [[UIImage alloc] initWithData:data];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   img, @"picture",
                                   nil];
    
    [self.FB requestWithGraphPath:@"me/photos"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
    
    [img release];
}

////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    if ([result objectForKey:@"owner"]) {
        NSLog(@"Photo upload Success");
    } else {
        NSLog(@"Request returned name %@", [result objectForKey:@"name"]);
    }
};

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request Failed: %@", [error localizedDescription]);
    NSLog(@"Error Details: %@", [error description]);
};


////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"publish successfully");
}


@end
