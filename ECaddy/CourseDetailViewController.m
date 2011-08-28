//
//  CourseDetailViewController.m
//  SMTG
//
//  Created by RKing on 5/19/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "SMTGAppDelegate.h"
#import "Course.h"
#import <QuartzCore/QuartzCore.h>

@implementation CourseDetailViewController

#define BORDER_WIDTH    2.0f

@synthesize tableV;
@synthesize titleView;
@synthesize courseNameLbl;
@synthesize favstarBtn;
@synthesize footView;
@synthesize courseObj;
@synthesize numSects;
@synthesize addrStr;
@synthesize manObjCon;

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
    [courseObj release];
    [favstarBtn release];
    [manObjCon release];
    [courseNameLbl release];
    [titleView release];
    [tableV release];
    [footView release];
    [addrStr release];
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

    [self.tableV setBackgroundColor: [UIColor clearColor]];
    
    // Set up borders for the top level views
    self.titleView.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.titleView.layer.borderWidth = BORDER_WIDTH;
    self.tableV.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
    self.tableV.layer.borderWidth = BORDER_WIDTH;
    
    // Add the buttons to the footer view
    self.tableV.tableFooterView = self.footView;
    
    // Set the navigation bar title
    [self.navigationItem setTitle: @"Course Info"];
    
    // Set the course title name
    [self.courseNameLbl setText: self.courseObj.coursename];
    
    // Set the address string
    NSString* streetStr = nil;
    NSString* cityStr = nil;
    NSString* lblStr = @"";
    
    NSString* addr = [self.courseObj valueForKey: @"address"];
    
    if([[addr componentsSeparatedByString: @","] count] != 1){
        streetStr = [[addr componentsSeparatedByString: @","] objectAtIndex: 0];
        cityStr = [[addr componentsSeparatedByString: @","] objectAtIndex: 1];
        cityStr = [cityStr stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        lblStr = [lblStr stringByAppendingFormat: @"%@\n", streetStr];
    }
    else{
        cityStr = addr;
    }
    
    self.addrStr = [lblStr stringByAppendingFormat: @"%@, %@\n%@", cityStr,
              [self.courseObj valueForKey:@"state"], 
              [self.courseObj valueForKey: @"country"]];
    
    // Set the number of sections based on the available info
    self.numSects = 1;
    if(self.courseObj.phone)
        self.numSects++;
    if(self.courseObj.website && (![self.courseObj.website isEqualToString: @""]))
        self.numSects++;
    
    // Set the inital state of the favorite star
    BOOL isFav = [[self.courseObj favorite] boolValue];
    [self.favstarBtn setImage: [UIImage imageNamed: (isFav ? @"favstarpressed.png" : 
                                    @"favstarreleased.png")] forState:UIControlStateNormal];
    
    self.manObjCon = nil;
}

- (void)viewDidUnload
{
    [self setCourseObj: nil];
    [self setFavstarBtn: nil];
    [self setManObjCon: nil];
    [self setCourseNameLbl:nil];
    [self setTitleView:nil];
    [self setTableV:nil];
    [self setFootView:nil];
    [self setAddrStr: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (IBAction)startRoundClicked:(id)sender {
    
    [self.tabBarController setSelectedViewController: [self.tabBarController.viewControllers objectAtIndex: 0]];
    UINavigationController* navCont = (UINavigationController*) self.tabBarController.selectedViewController;
    [[[navCont viewControllers] objectAtIndex: 0] setCourseObj: self.courseObj];
    [navCont popToRootViewControllerAnimated: NO];
    [[[navCont viewControllers] objectAtIndex: 0] viewDidAppear: YES];
    
    return;
}

- (IBAction) favstarPressed:(id)sender
{
   SMTGAppDelegate* appDel = [SMTGAppDelegate sharedAppDelegate];
  
    if(!self.manObjCon){
        self.manObjCon = [appDel managedObjectContext];
    }
    
    BOOL fav = [[self.courseObj favorite] boolValue];
 
    fav = !fav;
    [self.favstarBtn setImage: [UIImage imageNamed: (fav ? @"favstarpressed.png" : 
                                    @"favstarreleased.png")] forState: UIControlStateNormal];
    
    [self.courseObj setFavorite: [NSNumber numberWithBool: fav]];

    // Save the managed object context to save the favorite change
    [appDel saveContext];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numSects;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    UILabel* lbl = [cell textLabel];
    UILabel* lbl2 = [cell detailTextLabel];
    
    switch (indexPath.section) {
        case kADDR_SECT:
            [lbl setText: @"Address"];
            [lbl2 setNumberOfLines: 0];
            [lbl2 setText: self.addrStr];
            break;
        case kPHONE_SECT:
            [lbl setText: @"Phone"];
            NSRange phoneR;
            if([self.courseObj.phone length] == 7){
                phoneR = NSMakeRange(0, 3);
                NSString* first3 = [self.courseObj.phone substringWithRange: phoneR];
                phoneR = NSMakeRange(3, 4);
                NSString* last4 = [self.courseObj.phone substringWithRange: phoneR];
                
                [lbl2 setText: [NSString stringWithFormat: @"%@-%@", first3, last4]];
            }
            else if([self.courseObj.phone length] == 10){
                phoneR = NSMakeRange(0, 3);
                NSString* first3 = [self.courseObj.phone substringWithRange: phoneR];
                phoneR = NSMakeRange(3, 3);
                NSString* second3 = [self.courseObj.phone substringWithRange: phoneR];
                phoneR = NSMakeRange(6, 4);
                NSString* last4 = [self.courseObj.phone substringWithRange: phoneR];
                
                [lbl2 setText: [NSString stringWithFormat: @"(%@) %@-%@", first3, second3, last4]];
            }
            else{
                [lbl2 setText: self.courseObj.phone];
            }
            break;
        case kWEBSITE_SECT:
            [lbl setText:@"Website"];
            [lbl2 setText: self.courseObj.website];
            break;
        default:
            [lbl2 setText: @""];
            break;
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleBlue];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retVal = 44.0f;
    
    if(indexPath.section == kADDR_SECT){
        CGSize size = [self.addrStr sizeWithFont:[UIFont systemFontOfSize: 17.0f] constrainedToSize:CGSizeMake(268.0, 2000.0) lineBreakMode:UILineBreakModeWordWrap];
        retVal = size.height + 10.0f;
    }
    
    return retVal;
}

#pragma mark - Table view delegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    NSString* actSheetBtnTitle = nil;
    
    if(indexPath.section == kADDR_SECT){
        // Display the address in maps best we can
        actSheetBtnTitle = @"Open in Maps";
    }
    else if(indexPath.section == kPHONE_SECT){
        // Display call in actionsheet
        actSheetBtnTitle = @"Call";
    }
    else if(indexPath.section == kWEBSITE_SECT){
        // Display open in actionsheet
        actSheetBtnTitle = @"Open Site";
    }

    // Clicked a section without an associated action
    if(!actSheetBtnTitle)
        return;
    
    NSString* titleStr = [[[tableView cellForRowAtIndexPath: indexPath] detailTextLabel] text];
    UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle: titleStr delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil otherButtonTitles: actSheetBtnTitle, nil];
    actSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actSheet showFromTabBar: self.tabBarController.tabBar];
    [actSheet release];
}

#pragma mark - UIActionSheetDelegate Method
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* urlStr = nil;
    NSString* btnTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
    
    if( [btnTitle isEqualToString: @"Open in Maps"]){
        NSString* courseAddr = [actionSheet title];
        courseAddr = [courseAddr stringByReplacingOccurrencesOfString:@"\n" withString:@"%20"];
        courseAddr = [courseAddr stringByReplacingOccurrencesOfString: @" " withString:@"%20"];
        urlStr = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@", courseAddr];
    }
    else if([btnTitle isEqualToString: @"Call"]){
        urlStr = [NSString stringWithFormat: @"tel:%@", self.courseObj.phone];
    }
    else if([btnTitle isEqualToString: @"Open Site"]){
        if([self.courseObj.website hasPrefix: @"http://"])
            urlStr = self.courseObj.website;
        else
            urlStr = [NSString stringWithFormat: @"http://%@", self.courseObj.website];
    }
    
    NSURL* url = [NSURL URLWithString: urlStr];
    [[UIApplication sharedApplication] openURL: url];
}

@end
