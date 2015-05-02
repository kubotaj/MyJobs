//
//  SettingsViewController.h
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UserSettings.h"

@interface SettingsViewController : UIViewController<UITextFieldDelegate>



- (instancetype) initWithSettings: (UserSettings *) us;
-(void) updateUserSettings;

@end
