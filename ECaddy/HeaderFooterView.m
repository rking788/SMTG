//
//  HeaderFooterView.m
//  ECaddy
//
//  Created by RKing on 6/9/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "HeaderFooterView.h"
#import "ScoreTrackerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HeaderFooterView

@synthesize numCols;
@synthesize headerOrFooter;
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

#pragma mark - TODO The way the default player is inserted is really messed up it should be done correctly
- (void) addHeaderColumnsForNumPlayers: (NSUInteger) numPlayers
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
    
    // TODO: This is really fudged right now. Should be done correctly
    // Check for a default player name
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* defaultFirstPlayer = [defaults objectForKey: @"name"];
    if(defaultFirstPlayer){
        [playerNames replaceObjectAtIndex:0 withObject: defaultFirstPlayer];
        [(UITextField*)[self viewWithTag: (kPAR_TAG + 1)] setText: defaultFirstPlayer];
    }
    self.playerNamesArr = [[NSArray alloc] initWithArray: playerNames];
    
    [playerNames release];
}

- (void) addFooterColumnsForNumPlayers: (NSUInteger) numPlayers
{
    CGFloat constColSize = 45.0;
    NSUInteger i = 0;
    NSString* fontStr = @"Helvetica";
    
    // Set up two constant columns for the "Hole #" and "Par" values
    CGRect rect1 = CGRectMake(0, 0, (constColSize * 2) + 1, self.bounds.size.height);
    UILabel* totalLabel = [[UILabel alloc] initWithFrame: rect1];
    [totalLabel setText: @"TOTAL"];
    [totalLabel setFont: [UIFont fontWithName: @"Helvetica Bold" size: 14.0]];
  //  [totalLabel setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    [totalLabel setTextAlignment: UITextAlignmentCenter];
   // [totalLabel setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [totalLabel setMinimumFontSize: (CGFloat) 12.0];
    [totalLabel setAdjustsFontSizeToFitWidth: YES];
   // [totalLabel setBorderStyle: UITextBorderStyleLine];
    [totalLabel setEnabled: YES];
    [totalLabel setTag: kTOTAL_TAG];
    
    totalLabel.layer.borderColor = [UIColor blackColor].CGColor;
    totalLabel.layer.borderWidth = 1.0;
    
    // Add the constant columns as subviews
    [self addSubview: totalLabel];
    
    [totalLabel release];
    
    // Set a variable number of columns that is equal to the number of players playing
    CGRect playerTotRect;
    UITextField* playerTotTF;
    CGFloat varColWidth = (CGFloat)((self.bounds.size.width - (2 * constColSize))/ numPlayers);
    CGFloat varColOffset = ((constColSize) * 2);;
    
    for(i = 0; i < numPlayers; i++){
        // Setup the TextField with a calculated CGRect
        playerTotRect = CGRectMake((varColOffset + (i * varColWidth)), 0, varColWidth, self.bounds.size.height);
        playerTotTF = [[UITextField alloc] initWithFrame: playerTotRect];
        
        // Set up the text field to be entered in the header
        [playerTotTF setText: @"-"];
        [playerTotTF setTextAlignment: UITextAlignmentCenter];
        [playerTotTF setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [playerTotTF setAdjustsFontSizeToFitWidth: YES];
        [playerTotTF setMinimumFontSize: 8];
        [playerTotTF setBorderStyle: UITextBorderStyleLine];
        [playerTotTF setFont: [UIFont fontWithName: fontStr size: 17.0]];
        [playerTotTF setDelegate: self];
        [playerTotTF setReturnKeyType: UIReturnKeyDone];
        [playerTotTF setTag: ((kTOTAL_TAG + 1) + i)];
        [playerTotTF setUserInteractionEnabled: NO];
        
        [self addSubview: playerTotTF];
        
        [playerTotTF release];
    }
}

- (void) setTotalsWithScoreDict: (NSMutableDictionary*) scoreDict
{
    NSUInteger tag = kTOTAL_TAG;
    NSInteger total;
    UITextField* textField;
    
    for(UIView* view in self.subviews){
        tag = view.tag;
        
        if(tag <= kTOTAL_TAG)
            continue;
        
        total = -1;
        textField = (UITextField*) view;
        NSString* name = [self stringForNameInCol: [HeaderFooterView colFromTag: tag]];
        NSArray* scores = [scoreDict objectForKey: name];
        for(id score in scores){
            if([score isKindOfClass: [NSNumber class]]){
                if (total != -1) {
                    total += [score intValue];
                }
                else{
                    total = [score intValue];
                }
            }
        }
        
        // Set the text field to the total or a - 
        if(total != -1)
            [textField setText: [NSString stringWithFormat: @"%d", total]];
        else
            [textField setText: @"-"];
    }
}

+ (NSUInteger) colFromTag:(NSUInteger)tag
{
    return [[NSNumber numberWithUnsignedInt: (tag - (kTOTAL_TAG + 1))] unsignedIntValue];
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
    return [self.playerNamesArr componentsJoinedByString: @";"];
}

- (NSString*) stringForNameInCol: (NSUInteger) col
{
    return [self.playerNamesArr objectAtIndex: col];
}

- (void)dealloc
{
    [playerNamesArr release];
    [headerOrFooter release];
    [super dealloc];
}

@end
