//
//  WeatherDetails.h
//  ECaddy
//
//  Created by Teacher on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeatherDetails : UIViewController {
    NSString* text;
    UITextView *textView;
    UINavigationBar *navBar;
    UIImageView *weatherPic;
}
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIImageView *weatherPic;

- (void) cancel;

@end
