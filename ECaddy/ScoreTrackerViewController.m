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
#import "FBConnect.h"
#import <QuartzCore/QuartzCore.h>

// Facebook app ID constant string
static NSString* kAppId = @"142876775786876";


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
@synthesize FB = _FB;
@synthesize FBpermissions;
@synthesize FBLoggedIn;
@synthesize pendingFBAction;

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
    [dateLbl release];
    [backgroundImageView release];
    [titleView release];
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
    
    self.appDel = [SMTGAppDelegate sharedAppDelegate];
    
    // Register listeners for keyboard notifications
    [self registerForKeyboardNotifications];
    
    // TODO: Finish implementing this to provide actions like posting to facebook and finishing a round
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                               target:self action:@selector(actionButtonClicked:)] autorelease];
    
    self.navigationItem.title = @"Scorecard";
    
    // Create the Facebook instance
    self.FBLoggedIn = NO;
    _FB = [[Facebook alloc] initWithAppId:kAppId];
    [[SMTGAppDelegate sharedAppDelegate] setFBInstance: self.FB];
    
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
        
        [dateF release];
        
        [self.favstarBtn setImage: [UIImage imageNamed: ([[self.scorecard.course favorite] boolValue] ? @"favstarpressed.png" : @"favstarreleased.png")] forState: UIControlStateNormal];
        
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
    [self setDateLbl:nil];
    [self setBackgroundImageView:nil];
    [self setTitleView:nil];
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
    
    NSMutableDictionary* scoresdict = [self.scorecard.scores mutableCopy];
    if(scoresdict){
        self.scorecardDict = scoresdict;
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
        cell = [[[ScorecardTableCell alloc] initWithFrame:CGRectZero reuseIdentifier: cellID] autorelease];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
        label = [[[UILabel alloc] initWithFrame: CGRectMake(0.0, 0.0, constColWidth-1, tableView.rowHeight)] autorelease];
        
        [cell addColumn: 44];
        label.tag = HOLENUM_TAG;
        label.font = [UIFont systemFontOfSize: 17.0];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = bgColor;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview: label];
    
        label = [[[UILabel alloc] initWithFrame: CGRectMake(constColWidth, 0, constColWidth, tableView.rowHeight)] autorelease];
        
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
    
    // Update the scorecard managed object
    [self.appDel saveCurScorecard: self.scorecardDict];
    
    [rowCol release];
    [f release];
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
    UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: @"Finish Round" otherButtonTitles: @"Upload to Facebook", nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showFromTabBar: self.tabBarController.tabBar];
    [actSheet release];  
}

#pragma mark - UIActionSheetDelegate Method
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* selTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    if([selTitle isEqualToString: @"Upload to Facebook"]){
#ifdef LITE
        UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Sorry" message: @"Sorry, this feature is only available in the Full version." delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
        
        [av show];
#else
        [self saveScorecardImg];
        [self uploadSCToFB];
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
    HeaderFooterView* secondFooter = nil;
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
        [secondHeader addHeaderColumnsForNumPlayers: [[self.scorecard numplayers] unsignedIntValue]];
        [secondHeader setHeaderOrFooter: @"Header"];
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
        
        [tabv release];
        [secondHeader release];
       // [secondFooter release];
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


#pragma mark - Facebook Methods

- (void) login
{
    [self.FB authorize: self.FBpermissions delegate: self];
}

- (void) logout
{
    [self.FB logout: self];
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    self.FBLoggedIn = YES;
    if([self.pendingFBAction isEqualToString: @"photo"]){
        [self uploadPhoto];
    }
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    self.FBLoggedIn = NO;
    NSLog(@"Failed logging in to Facebook");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    self.FBLoggedIn = NO;
}

- (void) uploadSCToFB
{
    if(![self isFBLoggedIn]){
        [self login];
        self.FBLoggedIn = YES;
        self.pendingFBAction = @"photo";
    }
    else{
        [self uploadPhoto];
    }
}

/**
 * Open an inline dialog that allows the logged in user to publish a story to his or
 * her wall.
 */
#if 0
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
#endif

/**
 * Upload a photo.
 */
- (void)uploadPhoto
{
    NSString* documentsDir = [[SMTGAppDelegate sharedAppDelegate] applicationDocumentsDirectory];
    NSString *filePath =  [documentsDir stringByAppendingPathComponent: @"Screenshot.png"];
    NSData* data = [NSData dataWithContentsOfFile: filePath];
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
    UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Success" message: @"Successfully uploaded scorecard to Facebook" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
    
    [av show];
    
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
    UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Error" message: @"An error occurred uploading the scorecard.\nPlease try again later." delegate:self cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
    
    [av show];
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
