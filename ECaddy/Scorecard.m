//
//  Scorecard.m
//  SMTG
//
//  Created by RKing on 6/4/11.
//  Copyright (c) 2011 RPKing. All rights reserved.
//

#import "Scorecard.h"
#import "Course.h"
#import "constants.h"

@implementation Scorecard
@dynamic active;
@dynamic dateplayed;
@dynamic scores;
@dynamic playernames;
@dynamic numplayers;
@dynamic course;

- (NSDictionary*) scoreDictForSC
{
    // If the scores object is a dictionary (old version of app)
    // just return it
    if([self.scores isKindOfClass: [NSDictionary class]]){
        return self.scores;
    }
    
    // The updated app stores the scores as an NSData object so it will need to unarchived
    NSData *data = self.scores;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey: SCORESARCHIVESTR];
    [unarchiver finishDecoding];

    return myDictionary;
}

- (void) updateScores: (NSDictionary*) scoreDict
{
    // Store the scores transformable property as an NSData object
    NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject: scoreDict forKey: SCORESARCHIVESTR];
	[archiver finishEncoding];
    
    self.scores = data;
}

@end
