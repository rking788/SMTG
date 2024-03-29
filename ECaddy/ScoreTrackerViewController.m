//
//  ScoreTrackerViewController.m
//  SMTG
//
//  Created by RKing on 6/6/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "ScoreTrackerViewController.h"
#import "ScorecardTableCell.h"
#import "SMTGAppDelegate.h"
#import "Scorecard.h"
#import "Course.h"
#import "HeaderFooterView.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#pragma mark - TODO CRITICAL: Do some debugging with changing views and stuff back and forth to fix persistence and crashing issues

// Facebook app ID constant string
static NSString* kAppId = @"142876775786876";
NSString *const FBSessionStateChangedNotification =
@"com.mainelyapps.SMTG.Login:FBSessionStateChangedNotification";


@implementation ScoreTrackerViewController

@synthesize appDel;
@synthesize scorecard;
@synthesize scoreHeaderView;
@synthesize scoreFooterView;
@synthesize titleView;
@synthesize titleTextView;
@synthesize dateLbl;
@synthesize favstarBtn;
@synthesize scorecardDict;
@synthesize tableV;
@synthesize backgroundImageView;
@synthesize activeField;

// TODO CRITICAL : When tweeting a scorecard, the twitter view controller is shown and then when it is dismissed the view is shifted down (after the keyboard goes away) and a white background is shown at the top 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    
    self.appDel = [SMTGAppDelegate sharedAppDelegate];
    
    // Register listeners for keyboard notifications
    [self registerForKeyboardNotifications];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                               target:self action:@selector(actionButtonClicked:)];
    
    self.navigationItem.title = @"Scorecard";
  
    if(self.scorecard){
        NSString* name;
        NSString* date;
        NSDateFormatter* dateF;
        
        name = [[self.scorecard course] coursename];
        dateF = [[NSDateFormatter alloc] init];
        [dateF setDateFormat: @"MM/dd/yyyy hh:mm"];
        
        date = [dateF stringFromDate: [self.scorecard dateplayed]];
        [self.titleTextView setText: name];
        [self.dateLbl setText: date];
 
        // Give the header and footer views a reference to us to alert us of changes
        [self.scoreHeaderView setScoreTracker: (ScoreTrackerViewController*) self];
        [self.scoreFooterView setScoreTracker: (ScoreTrackerViewController*) self];
        
        
        [self.favstarBtn setImage: [UIImage imageNamed: ([[self.scorecard.course favorite] boolValue] ? @"favstarpressed.png" : @"favstarreleased.png")] forState: UIControlStateNormal];
        
        NSUInteger num = [[self.scorecard numplayers] unsignedIntegerValue];
        
        // Add the right number of names to the header of the table view
        [self.scoreHeaderView setHeaderOrFooter: @"Header"];
        [self.scoreHeaderView addHeaderColumnsForNumPlayers: num];
        
        [self.scoreFooterView setHeaderOrFooter: @"Footer"];
        [self.scoreFooterView addFooterColumnsForNumPlayers: num];
        
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
        }

    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setTableV:nil];
    [self setDateLbl:nil];
    [self setBackgroundImageView:nil];
    [self setTitleView:nil];
    [self setAppDel: nil];
    [self setScorecard: nil];
    [self setTitleTextView:nil];
    [self setScoreHeaderView:nil];
    [self setScoreFooterView:nil];
    [self setFavstarBtn:nil];
//    [self setFBpermissions: nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setScorecardDict: nil];
}

- (void) viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear: animated];
    // Load the players scores from the current scorecard object
    
    NSMutableDictionary* scoresdict = [[self.scorecard scoreDictForSC] mutableCopy];//[self.scorecard.scores mutableCopy];
    if(scoresdict){
        [self setScorecardDict: scoresdict];
        [self.scoreHeaderView setPlayers: [self.scorecardDict allKeys]];
        [self.scoreFooterView setPlayers: [self.scorecardDict allKeys]];
    }
    
    // Update the totals in the footer view
    [self.scoreFooterView setTotalsWithScoreDict: self.scorecardDict];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    // Save the players scores to the sqlite store
    [self.appDel saveCurScorecard: self.scorecardDict];
    
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
    NSInteger num = [self.scorecard.course.numholes integerValue];
    
    return num;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:NO];    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifierEven = @"CourseTableCellEven";
    static NSString *CellIdentifierOdd = @"CourseTableCellOdd";
    static const NSUInteger constColWidth = 45;
    UILabel* label;
    
    NSString* cellID = nil;
    UIColor* bgColor = nil;
    if((indexPath.row % 2) == 0){
        cellID = CellIdentifierEven;
        //bgColor = [UIColor colorWithRed:0.59 green:0.75 blue:0.63 alpha:1.0];
        bgColor = [UIColor colorWithRed:0.8 green:1.0 blue:0.82 alpha:1.0];
    }
    else{
        cellID = CellIdentifierOdd;
        //bgColor = [UIColor colorWithRed:0.79 green:1.0 blue:0.84 alpha:1.0];
        bgColor = [UIColor colorWithRed:0.49 green:0.8 blue:0.52 alpha:1.0];
    }
    
    ScorecardTableCell *cell = (ScorecardTableCell*) [tableView dequeueReusableCellWithIdentifier: cellID];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[ScorecardTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
        label = [[UILabel alloc] initWithFrame: CGRectMake(0.0, 0.0, constColWidth-1, tableView.rowHeight)];
        
        [cell addColumn: 44];
        label.tag = HOLENUM_TAG;
        label.font = [UIFont systemFontOfSize: 17.0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = bgColor;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview: label];
    
        label = [[UILabel alloc] initWithFrame: CGRectMake(constColWidth, 0, constColWidth, tableView.rowHeight)];
        
        [cell addColumn: 90];
        label.tag = PAR_TAG;
        label.font = [UIFont systemFontOfSize: 17.0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = bgColor;
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
            
            [scoreTF setPlaceholder: @"-"];
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
        view.backgroundColor = bgColor;
        if(view.tag == HOLENUM_TAG || view.tag == PAR_TAG){
            continue;
        }
        if(view.tag == 0){
            continue;
        }

        field = (UITextField*) view;
        field.tag = [ScoreTrackerViewController tagFromRow: indexPath.row AndCol: col];
        field.text = [self stringForScoreWithRow:indexPath.row AndCol: [[[ScoreTrackerViewController rowAndColFromTag: field.tag] objectAtIndex: 1] unsignedIntegerValue]];
       
        // Only increment the column number if it is a textfield column
        col++;
    }
    
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
    if(!copyValue)
        return;
    
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
   
    NSArray* rowCol = [ScoreTrackerViewController rowAndColFromTag: textField.tag];
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
    
    // Update the scorecard managed object
    [self.appDel saveCurScorecard: self.scorecardDict];
    
}

- (IBAction)favstarPressed:(id)sender {
    BOOL fav = [[self.scorecard.course favorite] boolValue];
    
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstarpressed.png" : 
                                                     @"favstarreleased.png")] forState: UIControlStateNormal];
    
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
    CGPoint bottom = CGPointMake(activeField.superview.frame.origin.x,
                                 (activeField.superview.frame.origin.y + activeField.superview.frame.size.height));
    //if (!CGRectContainsPoint(aRect, activeField.superview.frame.origin) ) {
    if (!CGRectContainsPoint(aRect, bottom) ) {
        //CGPoint scrollPoint = CGPointMake(0.0, activeField.superview.frame.origin.y-kbSize.height);
        [self.tableV scrollRectToVisible: self.activeField.superview.frame animated:YES];
        // [self.tableV setContentOffset:scrollPoint animated:YES];
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

- (void) actionButtonClicked: (id) sender
{
    UIActionSheet* actSheet;

    actSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self
                    cancelButtonTitle: @"Cancel"
                    destructiveButtonTitle: @"Finish Round"
                    otherButtonTitles: @"Upload to Facebook", @"Tweet", nil];
        
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showFromTabBar: self.tabBarController.tabBar];
}

#pragma mark - UIActionSheetDelegate Method
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* selTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    if([selTitle isEqualToString: @"Upload to Facebook"]){
#ifdef LITE
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Sorry" message: @"Sorry, this feature is only available in the Full version." delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
        
        [av show];
        return;
#else
        [self saveScorecardImg];
        [self uploadSCToFB];
#endif
    }
    else if([selTitle isEqualToString: @"Tweet"]){
#ifdef LITE
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Sorry" message: @"Sorry, this feature is only available in the Full version." delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
        
        [av show];
        return;
#else
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        // Set the initial tweet text. See the framework for additional properties that can be set.
        
        NSString* initText = [NSString stringWithFormat: @"Played a round of golf at %@ #SMTGoniOS", [self.scorecard.course coursename]];
        [tweetViewController setInitialText: initText];
        
        [self saveScorecardImg];
        
        NSString* documentsDir = [[SMTGAppDelegate sharedAppDelegate] applicationDocumentsDirectory];
        NSString *filePath =  [documentsDir stringByAppendingPathComponent: @"Screenshot.png"];
        NSData* data = [NSData dataWithContentsOfFile: filePath];
        UIImage *img  = [[UIImage alloc] initWithData:data];
        
        [tweetViewController addImage: img];
        
        // Create the completion handler block.
        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            //NSString *output;
            
           /* switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    // The cancel button was tapped.
                    output = @"Tweet cancelled.";
                    break;
                case TWTweetComposeViewControllerResultDone:
                    // The tweet was sent.
                    output = @"Tweet done.";
                    break;
                default:
                    break;
            }*/
            
            [self performSelectorOnMainThread: @selector(keyboardWillBeHidden:) withObject:nil waitUntilDone: NO];
            //[self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
            
            // Dismiss the tweet composition view controller.
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        // Present the tweet composition view controller modally.
        [self presentModalViewController:tweetViewController animated:YES];
#endif
    }
    else if([selTitle isEqualToString: @"Finish Round"]){
        // Set the scorecard active to NO and go back to the root view controller.
        self.scorecard.active = [NSNumber numberWithBool: NO];
        
        [self.appDel saveCurScorecard: self.scorecardDict];
        
        self.scorecard = nil;
        [self.appDel setCurCourse: nil];
        [self.appDel setCurScorecard: nil];
        
        [self.navigationController popToRootViewControllerAnimated: YES];
    }
}

#pragma mark - Methods to export view to PNG

- (void) saveScorecardImg
{
    NSUInteger numHoles = [self.scorecard.course.numholes unsignedIntValue];
    BOOL isExtended = NO;
    if(numHoles >= 10){
        isExtended = YES;
    }
    else{
        isExtended = NO;
    }
    
    CGFloat tableHeight = self.tableV.rowHeight * 9;
    CGRect newTVF = self.tableV.frame;
    CGRect originalTVF = newTVF;
    newTVF.size.height = tableHeight;
    self.tableV.frame = newTVF;
    
    // Change the origin of the footer view
    CGRect footerVframe = self.scoreFooterView.frame;
    CGRect originalFVF = footerVframe;
    
    footerVframe.origin.y = self.tableV.frame.origin.y + tableHeight;
    self.scoreFooterView.frame = footerVframe;
    
    CGFloat overall_width = self.tableV.frame.size.width*2;
    if (isExtended) {
        overall_width = self.tableV.frame.size.width * 2;
    }
    else{
        overall_width = self.tableV.frame.size.width;
    }
    CGFloat overall_height = footerVframe.origin.y + footerVframe.size.height;
    
    CGRect backgroundRect = self.backgroundImageView.frame;
    CGRect origBackgroundRect = backgroundRect;
    backgroundRect.size.height = overall_height;
    backgroundRect.size.width = overall_width;
    self.backgroundImageView.frame = backgroundRect;
    
    NSIndexPath* fip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableV scrollToRowAtIndexPath: fip atScrollPosition: UITableViewScrollPositionTop animated: NO];
    
    // ONLY FOR 18 holes
    UITableView* tabv = nil;
    HeaderFooterView* secondHeader = nil;
    CGRect originalTitleRect = self.titleView.frame;
    if(isExtended){
        CGRect f = self.tableV.frame;
        f.origin.x = self.tableV.frame.size.width;
        tabv = [[UITableView alloc] initWithFrame:f  style:UITableViewStylePlain];
        [self.view addSubview: tabv];
        tabv.dataSource = self;
        tabv.delegate = self;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:10 inSection:0];
        [tabv scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        CGRect shFrame = self.scoreHeaderView.frame;
        shFrame.origin.x = self.scoreHeaderView.frame.size.width;
        secondHeader = [[HeaderFooterView alloc] initWithFrame: shFrame];
        [secondHeader setScoreTracker: (ScoreTrackerViewController*) self];
        
        [secondHeader setHeaderOrFooter: @"Header"];
        [secondHeader addHeaderColumnsForNumPlayers: [[self.scorecard numplayers] unsignedIntValue]];
        [secondHeader setPlayers: [self.scorecardDict allKeys]];
        [self.view addSubview: secondHeader];
        
       /* CGRect sfFrame = self.scoreFooterView.frame;
        sfFrame.origin.x = self.scoreFooterView.frame.size.width;
        sfFrame.origin.y = footerVframe.origin.y;
        secondFooter = [[HeaderFooterView alloc] initWithFrame: sfFrame];
        [secondFooter setScoreTracker: (ScoreTrackerViewController*) self];
        [secondFooter addFooterColumnsForNumPlayers: [[self.scorecard numplayers]unsignedIntValue]];
        [secondFooter setHeaderOrFooter: @"Footer"];    
        [secondFooter setPlayers: [self.scorecardDict allKeys]];
        [secondFooter setTotalsWithScoreDict: self.scorecardDict];
        [self.view addSubview: secondFooter];
        */
        footerVframe.origin.x = self.scoreFooterView.frame.size.width;
        self.scoreFooterView.frame = footerVframe;
        
        CGFloat newTitlex = originalTitleRect.origin.x + overall_width / 4;
        CGRect newTitleFrame = originalTitleRect;
        newTitleFrame.origin.x = newTitlex;
        self.titleView.frame = newTitleFrame;
    }
    
    [ScoreTrackerViewController savePNGForView: (UIView*) self.view rect:CGRectMake(0, 0, overall_width, overall_height) fileName: @"Screenshot.png"];

    // Restore the size of the table view
    self.tableV.frame = originalTVF;
    
    // Restore the origin of the footer view
    self.scoreFooterView.frame = originalFVF;
    
    // Restore the size of the background view
    self.backgroundImageView.frame = origBackgroundRect;
    
    // ONLY FOR 18 HOLES
    if(isExtended){
        self.titleView.frame = originalTitleRect;
    }
}

+ (BOOL) savePNGForView:(UIView *)targetView rect:(CGRect)rect fileName:(NSString *)fileName
{
    UIImage *image;
    CGPoint pt = rect.origin;
    BOOL ret = NO;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y));
    [targetView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    NSData *data = UIImagePNGRepresentation(image);
    NSString* documentsDir = [[SMTGAppDelegate sharedAppDelegate] applicationDocumentsDirectory];
    NSString *filePath =  [documentsDir stringByAppendingPathComponent: fileName];
    
    if ([data writeToFile:filePath atomically:YES]) {
        NSLog(@"Save OK");
        ret = YES;
        
    } else {
        NSLog(@"Save Error");
        ret = NO;
    }    
    
    return ret;
}

- (void) uploadSCToFB
{
    if(FBSession.activeSession.isOpen){
        [self uploadPhoto];
    }
    else {
        [self openSessionWithAllowLoginUI: YES];
    }
}

/**
 * Upload a photo.
 */
- (void)uploadPhoto
{
    NSString* documentsDir = [[SMTGAppDelegate sharedAppDelegate] applicationDocumentsDirectory];
    NSString *filePath =  [documentsDir stringByAppendingPathComponent: @"Screenshot.png"];
    NSData* data = [NSData dataWithContentsOfFile: filePath];
    UIImage *img  = [[UIImage alloc] initWithData:data];
   
    [FBRequestConnection startForUploadPhoto:img
                           completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                               UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Success" message:@"The scorecard was successfully uploaded." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                               [av show];
                           }];
}

#pragma mark - New Facebook iOS 3.0 SDK Methods
/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
                [self uploadPhoto];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray* permissions = @[@"publish_actions"];
    
    return [FBSession openActiveSessionWithPermissions: permissions
                                          allowLoginUI: allowLoginUI
                                     completionHandler: ^(FBSession *session,
                                                         FBSessionState state,
                                                         NSError *error) {
                                         [self sessionStateChanged:session
                                                             state:state
                                                             error:error];
                                     }];
}

@end
