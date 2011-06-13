//
//  HeaderFooterView.m
//  ECaddy
//
//  Created by RKing on 6/9/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "HeaderFooterView.h"
#import "ScoreTrackerViewController.h"

@implementation HeaderFooterView

@synthesize numCols;
@synthesize playerNamesArr;
@synthesize scoreTracker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setNumCols: 0];
        [self setPlayerNamesArr: nil];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) addColumnsForNumPlayers: (NSUInteger) numPlayers
{
    CGFloat constColSize = 45;
    NSUInteger i = 0;
    NSString* fontStr = @"Helvetica";
    NSMutableArray* playerNames = [[NSMutableArray alloc] initWithCapacity: numPlayers];
    
    // Set up two constant columns for the "Hole #" and "Par" values
    CGRect rect1 = CGRectMake(0, 0, constColSize, self.bounds.size.height);
    UITextField* holeTF = [[UITextField alloc] initWithFrame: rect1];
    [holeTF setText: @"Hole #"];
    [holeTF setFont: [UIFont fontWithName: fontStr size: 14.0]];
    [holeTF setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    [holeTF setTextAlignment: UITextAlignmentCenter];
    [holeTF setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [holeTF setMinimumFontSize: (CGFloat) 12.0];
    [holeTF setAdjustsFontSizeToFitWidth: YES];
    [holeTF setBorderStyle: UITextBorderStyleLine];
    [holeTF setEnabled: NO];
    [holeTF setTag: kNUMHOLE_TAG];

    CGRect rect2 = CGRectMake((constColSize), 0, constColSize, self.bounds.size.height);
    UITextField* parTF = [[UITextField alloc] initWithFrame: rect2];
    [parTF setText: @"Par"];
    [parTF setFont: [UIFont fontWithName: fontStr size: (CGFloat) 14.0]];
    [parTF setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    [parTF setTextAlignment: UITextAlignmentCenter];
    [parTF setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [parTF setMinimumFontSize: (CGFloat) 12.0];
    [parTF setAdjustsFontSizeToFitWidth: YES];
    [parTF setBorderStyle: UITextBorderStyleLine];
    [parTF setEnabled: NO];
    [parTF setTag: kPAR_TAG];

    // Add the constant columns as subviews
    [self addSubview: holeTF];
    [self addSubview: parTF];
    
    [holeTF release];
    [parTF release];
    
    // Set a variable number of columns that is equal to the number of players playing
    CGRect nameRect;
    UITextField* nameTF;
    CGFloat varColWidth = (CGFloat)((self.bounds.size.width - (2 * constColSize))/ numPlayers);
    CGFloat varColOffset = ((constColSize) * 2);;
    NSString* playerName = nil;
    
    for(i = 0; i < numPlayers; i++){
        // Setup the TextField with a calculated CGRect
        nameRect = CGRectMake((varColOffset + (i * varColWidth)), 0, varColWidth, self.bounds.size.height);
        nameTF = [[UITextField alloc] initWithFrame: nameRect];
        
        playerName = [NSString stringWithFormat: @"Name %d", (i + 1)];
        [playerNames addObject: playerName];
        
        // Set up the text field to be entered in the header
        [nameTF setPlaceholder: playerName];
        [nameTF setTextAlignment: UITextAlignmentCenter];
        [nameTF setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [nameTF setAdjustsFontSizeToFitWidth: YES];
        [nameTF setMinimumFontSize: 8];
        [nameTF setBorderStyle: UITextBorderStyleLine];
        [nameTF setFont: [UIFont fontWithName: fontStr size: 17.0]];
        [nameTF setDelegate: self];
        [nameTF setReturnKeyType: UIReturnKeyDone];
        [nameTF setTag: (kPAR_TAG + (i + 1))];
        
        [self addSubview: nameTF];
        
        [nameTF release];
    }
    
    self.playerNamesArr = [[NSArray alloc] initWithArray: playerNames];
    [playerNames release];
}

# pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    NSUInteger index = textField.tag - kPAR_TAG - 1;
    NSString* oldName = [playerNamesArr objectAtIndex: index];
    
    NSMutableArray* tempArray = [self.playerNamesArr mutableCopy];
    [tempArray replaceObjectAtIndex: index withObject: textField.text];
    
    self.playerNamesArr = [[NSArray alloc] initWithArray: tempArray];
    [(ScoreTrackerViewController*) self.scoreTracker nameChangedFrom: oldName To: textField.text];
    
    [tempArray release];
}

- (NSString*) stringOfPlayers
{
    return [playerNamesArr componentsJoinedByString: @";"];
}

- (NSString*) stringForNameInCol: (NSUInteger) col
{
    return [playerNamesArr objectAtIndex: col];
}

- (void)dealloc
{
    [playerNamesArr release];
    [super dealloc];
}

@end
