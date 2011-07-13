//
//  dbinit.m
//  ECaddy
//
//  Created by RKing on 5/13/11.
//  Copyright 2011 RPKing. All rights reserved.
//

#import "dbinit.h"


@implementation dbinit

@synthesize manObjCon;

- (void) insertWOEIDS
{
    NSString* outFile = @"/Users/teacher/Desktop/golfcourses.csv.new";
    NSString* fileContents = [[NSString alloc] initWithContentsOfFile: @"/Users/teacher/Desktop/golfcourses.csv"];

    NSError* err = nil;
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    NSArray* lineFields = nil;
    NSEnumerator* enumer = [lines objectEnumerator];
    NSString* cur = [enumer nextObject]; 
    NSString* outputStr = @"";
    
    while(cur){
        if([cur length] != 0){
            
            sleep(1);
            
            lineFields = [cur componentsSeparatedByString: @";"];
            NSString* tempstr = [lineFields objectAtIndex:4];
            if([tempstr isEqualToString:@""]){
                NSString* addr = [lineFields objectAtIndex:1];
                NSArray* addrArr = [addr componentsSeparatedByString:@","];
                NSString* city = [addrArr objectAtIndex: 1];
                NSString* state = [addrArr objectAtIndex: 2];
                city = [city stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                state = [state stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                city = [city stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                NSString* urlStr = @"";
                urlStr = [urlStr stringByAppendingString: @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20geo.places%20where%20text%3D%22"];
                urlStr = [urlStr stringByAppendingString: city];
                urlStr = [urlStr stringByAppendingString:@"%20"];
                urlStr = [urlStr stringByAppendingString:state];
                urlStr = [urlStr stringByAppendingString:@"%22&format=xml"];
                
                NSURL* url = [NSURL URLWithString: urlStr];
                NSString* str = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                
                NSRange range1 = [str rangeOfString:@"<woeid>" options:NSLiteralSearch];
                NSRange range2 = [str rangeOfString:@"</woeid>" options:NSLiteralSearch];
                NSRange range3;
                range3.location = range1.location + range1.length;
                range3.length = range2.location - (range1.location+range1.length);
                NSString* str2 = [str substringWithRange:range3];
                
                NSLog(@"woeid = %@", str2);
                
                NSLog(@"City = %@", city);
                NSMutableArray* arrtemp = [[NSMutableArray alloc] initWithArray:lineFields];
                [arrtemp insertObject:str2 atIndex:4];
                outputStr = [outputStr stringByAppendingString: [arrtemp componentsJoinedByString:@";"]];
            }
            else{
                outputStr = [outputStr stringByAppendingString: cur];
            }
            
            outputStr = [outputStr stringByAppendingString: @"\n"];
            BOOL ret = [outputStr writeToFile:outFile atomically:YES encoding:NSUTF8StringEncoding error:&err];
            
            if(ret == NO){
                NSLog(@"Error writing to file%@", err);
            }
        }
        
        cur = (NSString*)[enumer nextObject];
    }
    
    [outputStr writeToFile:outFile atomically:YES encoding:NSUTF8StringEncoding error:&err];
    [fileContents release];
}

- (void) fillDB
{
    if(!manObjCon){
        NSLog(@"Error in fillDB: manObjCon == nil");
        return;
    }
        
    NSString* fileContents = [[NSString alloc] initWithContentsOfFile: @"/Users/teacher/Desktop/CourseDirectory.csv"];
    
    NSError* err = nil;
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    NSArray* lineFields = nil;
    NSEnumerator* enumer = [lines objectEnumerator];
    NSString* cur = [enumer nextObject];
    NSManagedObject* courseObj = nil; 
    NSCharacterSet* badChars = [NSCharacterSet  characterSetWithCharactersInString:@"\"*"];
    
    NSString* name = nil;
    NSString* phone = nil;
    NSString* website = nil;
    NSString* woeid = nil;
    NSString* addr = nil;
    NSString* state = nil;
    NSString* country = nil;
    NSString* enabled = @"1";
    NSString* favorite = @"0";
    NSString* pending = @"0";
    NSString* numHoles = nil;
    NSString* tmpMensPars = nil;
    NSString* tmpWomensPars = nil;
    NSArray* mensPars = nil;
    NSArray* womensPars = nil;
    NSString* tmpTeeCoordsStr = nil;
    NSString* tmpGreenCoordsStr = nil;
    NSArray* teeCoords = nil;
    NSArray* greenCoords = nil;
    
    BOOL isEnabled = YES;
    BOOL isFavorite = NO;
    BOOL isPending = NO;
    
    while(cur){
        if([cur length] != 0){
            lineFields = [cur componentsSeparatedByString: @";"];
            courseObj = [NSEntityDescription insertNewObjectForEntityForName: @"Course" inManagedObjectContext: manObjCon];
            
            name = [[lineFields objectAtIndex:1] stringByTrimmingCharactersInSet:badChars];
            addr = [[lineFields objectAtIndex:2] stringByTrimmingCharactersInSet:badChars];
            phone = [[lineFields objectAtIndex:3] stringByTrimmingCharactersInSet:badChars];
            website = [[lineFields objectAtIndex:4] stringByTrimmingCharactersInSet:badChars];
            woeid = [[lineFields objectAtIndex:5] stringByTrimmingCharactersInSet:badChars];
            state = [[lineFields objectAtIndex: 6] stringByTrimmingCharactersInSet:badChars];
            country = [[lineFields objectAtIndex: 7] stringByTrimmingCharactersInSet:badChars];
            enabled = [[lineFields objectAtIndex: 8] stringByTrimmingCharactersInSet: badChars];
            favorite = [[lineFields objectAtIndex: 9] stringByTrimmingCharactersInSet: badChars];
            numHoles = [[lineFields objectAtIndex: 10] stringByTrimmingCharactersInSet: badChars];
            tmpMensPars = [[lineFields objectAtIndex: 11] stringByTrimmingCharactersInSet: badChars];
            tmpWomensPars = [[lineFields objectAtIndex: 12] stringByTrimmingCharactersInSet: badChars];
            tmpTeeCoordsStr = [[lineFields objectAtIndex: 13] stringByTrimmingCharactersInSet: badChars];
            tmpGreenCoordsStr = [[lineFields objectAtIndex: 14] stringByTrimmingCharactersInSet: badChars];
            pending = [[lineFields objectAtIndex: 15] stringByTrimmingCharactersInSet: badChars];
            
            if([website isEqualToString:@"NULL"])
                website = nil;
            
            if([enabled isEqualToString:@"1"])
                isEnabled = YES;
            else
                isEnabled = NO;
            
            if([favorite isEqualToString: @"1"])
                isFavorite = YES;
            else
                isFavorite = NO;
            
            if([pending isEqualToString: @"1"])
                isPending = YES;
            else
                isPending = NO;
            
            // These are special cases (may need to be changed depending on the CSV format
            if([tmpMensPars length] == 0){
                mensPars = nil;
            }
            else{
                mensPars = [tmpMensPars componentsSeparatedByString: @","];
            }
            
            if([tmpWomensPars length] == 0){
                womensPars = nil;
            }
            else{
                womensPars = [tmpWomensPars componentsSeparatedByString: @","];
            }
            
            NSRange stringRange = [tmpTeeCoordsStr rangeOfString: @"\N"];
            if(stringRange.length > 0){
                teeCoords = nil;
            }
            else{
                teeCoords = [tmpTeeCoordsStr componentsSeparatedByString: @"*"];
            }

            stringRange = [tmpGreenCoordsStr rangeOfString: @"\N"];
            if(stringRange.length > 0){
                greenCoords = nil;
            }
            else{
                greenCoords = [tmpGreenCoordsStr componentsSeparatedByString: @"*"];
            }

            
            [courseObj setValue: name forKey: @"coursename"];
            [courseObj setValue: addr forKey: @"address"];
            [courseObj setValue: phone forKey: @"phone"];
            [courseObj setValue: website forKey: @"website"];
            [courseObj setValue: woeid forKey: @"woeid"];
            [courseObj setValue: state forKey: @"state"];
            [courseObj setValue: country forKey:@"country"];
            [courseObj setValue: [NSNumber numberWithBool: isEnabled] forKey:@"enabled"];
            [courseObj setValue: [NSNumber numberWithBool: isFavorite] forKey: @"favorite"];
            [courseObj setValue: [NSNumber numberWithInt: [numHoles intValue]] forKey: @"numholes"];
            [courseObj setValue: mensPars forKey: @"menpars"];
            [courseObj setValue: womensPars forKey: @"womenpars"];
            [courseObj setValue: teeCoords forKey: @"teeCoords"];
            [courseObj setValue: greenCoords forKey: @"greenCoords"];
            [courseObj setValue: [NSNumber numberWithBool: isPending] forKey: @"pending"];
        }

        cur = (NSString*)[enumer nextObject];
    }
    
    if(![self.manObjCon save:&err]){
        // Handle the error here
        NSLog(@"Failed to save the course objects to managedObjectContext");
    }
    
    [fileContents release];
   
}


@end
