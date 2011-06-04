//
//  WeatherViewController.m
//  ECaddy
//
//  Created by RKing on 4/27/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherDetails.h"


@implementation WeatherViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL ret = NO;
    
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        ret = YES;
    }
    else if(interfaceOrientation == UIInterfaceOrientationPortrait){
        ret = YES;
    }
    
    return ret;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark TableView Data Source Protocol 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // TODO: This number should be changed if there is no active course
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    // TODO: Change section number 1 number of rows to a variable number 
    if(section == 0)
        numRows = 1;
    else if(section == 1)
        numRows = 1;
    
    return numRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title;
    
    // TODO: This should be changed if there is no active course
    if(section == 0){
        title = @"Active Course";
    }
    else if(section == 1){
        title = @"Available Locations";
    }
    
    return title;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WeatherTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set up the cell...
    if(indexPath.section == 0){
        NSString *cellValue = @"Active Course";
        UILabel* lbl = [cell textLabel];
        [lbl setText: cellValue];
        UILabel* lbl2 = [cell detailTextLabel];
        [lbl2 setText: @"Old Town, ME"];
    }
    else if(indexPath.section == 1){
        NSString *cellValue = @"Available Course";
        UILabel* lbl = [cell textLabel];
        [lbl setText: cellValue];
        UILabel* lbl2 = [cell detailTextLabel];
        [lbl2 setText: @"Somewhere in Maine"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeatherDetails* weatherView = [[WeatherDetails alloc] initWithNibName:@"WeatherDetails" bundle:nil];
    
    // Set the course detail information from the selected tableview cell
    NSString* courseName = [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text];
    NSString* courseLoc = [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text];
    [weatherView setCourseName: courseName];
    [weatherView setCourseLoc: courseLoc];
    
    // Set the transition mode and display the weather detail view modally
    [weatherView setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:weatherView animated:YES];
    [weatherView release];
}

@end
