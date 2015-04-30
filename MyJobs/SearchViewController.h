//
//  SearchViewController.h
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "UserSettings.h"


@interface SearchViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction) clickedBackground;
- (instancetype) initWithSettings: (UserSettings *) us;

@end

