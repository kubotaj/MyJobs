//
//  SearchViewController.h
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>


@interface SearchViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction) clickedBackground;
- (NSComparisonResult)compareJob: (id) element with: (id) element2;

@end

