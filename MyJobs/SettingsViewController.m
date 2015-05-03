//
//  SettingsViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITextField *searchRadius;
@property (weak, nonatomic) IBOutlet UITextField *skill1;
@property (weak, nonatomic) IBOutlet UITextField *skill2;
@property (weak, nonatomic) IBOutlet UITextField *skill3;
@property (weak, nonatomic) IBOutlet UIView *settingsView;

@property (weak, nonatomic) PFUser *currUser;
@property (strong, nonatomic) UserSettings *currUserSettings;

@end

@implementation SettingsViewController

-(instancetype) initWithSettings: (UserSettings *) settings {
    if( (self = [super init]) == nil )
        return nil;

    self.currUserSettings = settings;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ViewDidLoad called");
    // Do any additional setup after loading the view from its nib.
    self.updateButton.layer.cornerRadius = 10;
    self.updateButton.clipsToBounds = true;
    //[self updateUserSettings];
//    self.currUser = [PFUser currentUser];
//    self.currUserSettings = [[UserSettings alloc] initWithDefault];
//    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
//    [query whereKey:@"userId" equalTo:self.currUser.objectId];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            PFObject *obj = [objects objectAtIndex:0];
//            self.currUserSettings.searchRadius = [[obj objectForKey:@"Radius"] intValue];
//            [self.currUserSettings addSkill:[obj objectForKey:@"Skill1"]];
//            [self.currUserSettings addSkill:[obj objectForKey:@"Skill2"]];
//            [self.currUserSettings addSkill:[obj objectForKey:@"Skill3"]];
//            
//            self.searchRadius.text = [NSString stringWithFormat:@"%li", (long)self.currUserSettings.searchRadius];
//            self.skill1.text = [self.currUserSettings.userSkills objectAtIndex:0];
//            self.skill2.text = [self.currUserSettings.userSkills objectAtIndex:1];
//            self.skill3.text = [self.currUserSettings.userSkills objectAtIndex:2];
//            
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];

    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    [self updateUserSettings];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateUserSettings { //fills in text fields from the current user's settings.
//    [self.currUserSettings clearSkills];
//    self.currUser = [PFUser currentUser];
//    //self.currUserSettings = [[UserSettings alloc] initWithDefault];
//    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
////    if (self.currUser.objectId != nil) {
//        [query whereKey:@"userId" equalTo:self.currUser.objectId];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                PFObject *obj = [objects objectAtIndex:0];
//                self.currUserSettings.searchRadius = [[obj objectForKey:@"Radius"] intValue];
//                if (![[obj objectForKey:@"Skill1"] isEqual:@""])
//                    [self.currUserSettings addSkill:[obj objectForKey:@"Skill1"]];
//                if (![[obj objectForKey:@"Skill2"] isEqual:@""])
//                    [self.currUserSettings addSkill:[obj objectForKey:@"Skill2"]];
//                if (![[obj objectForKey:@"Skill3"] isEqual:@""])
//                    [self.currUserSettings addSkill:[obj objectForKey:@"Skill3"]];
//            
//                self.searchRadius.text = [NSString stringWithFormat:@"%li", (long)self.currUserSettings.searchRadius];
//            
//                self.skill1.text = [self.currUserSettings.userSkills objectAtIndex:0];
//                self.skill2.text = [self.currUserSettings.userSkills objectAtIndex:1];
//                self.skill3.text = [self.currUserSettings.userSkills objectAtIndex:2];
//            
//            } else {
//                // Log details of the failure
//                NSLog(@"Error: %@ %@", error, [error userInfo]);
//            }
//        }];
////    }
    
    [self.currUserSettings updateUserSettings];
    self.searchRadius.text = [NSString stringWithFormat:@"%li", (long)self.currUserSettings.searchRadius];
    self.skill1.text = nil;
    self.skill2.text = nil;
    self.skill3.text = nil;
    if (self.currUserSettings.skillCount > 0) {
        if ([self.currUserSettings.userSkills objectAtIndex:0] != nil)
            self.skill1.text = [self.currUserSettings.userSkills objectAtIndex:0];
        
        if (self.currUserSettings.skillCount > 1 && [self.currUserSettings.userSkills objectAtIndex:1] != nil)
            self.skill2.text = [self.currUserSettings.userSkills objectAtIndex:1];
        
        if (self.currUserSettings.skillCount > 2 && [self.currUserSettings.userSkills objectAtIndex:2] != nil)
            self.skill3.text = [self.currUserSettings.userSkills objectAtIndex:2];
    }
}

- (IBAction)didTapUpdate:(id)sender {
    //[self.currUserSettings clearSkills];
    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    PFObject *object = [query getFirstObject];
    object[@"Radius"] = [[NSNumber alloc] initWithLong:[self.searchRadius.text integerValue]];
    object[@"Skill1"] = self.skill1.text;
    object[@"Skill2"] = self.skill2.text;
    object[@"Skill3"] = self.skill3.text;
    [object save];
    
    [self.currUserSettings updateUserSettings];
    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            PFObject *obj = [objects objectAtIndex:0];
//            NSNumber *num = [[NSNumber alloc] initWithLong:[self.searchRadius.text integerValue]];
//            obj[@"Radius"] = num;
//            obj[@"Skill1"] = self.skill1.text;
//            obj[@"Skill2"] = self.skill2.text;
//            obj[@"Skill3"] = self.skill3.text;
//            [obj save];
//            
//            self.currUserSettings.searchRadius = [self.searchRadius.text integerValue];
//            if (![self.skill1.text  isEqual: @""])
//                [self.currUserSettings addSkill:self.skill1.text];
//            if (![self.skill2.text  isEqual: @""])
//                [self.currUserSettings addSkill:self.skill2.text];
//            if (![self.skill3.text  isEqual: @""])
//                [self.currUserSettings addSkill:self.skill3.text];
//            
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
}

/* Dismiss keyboard when return key is tapped */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

/* Dismiss keyboard when empty space is tapped */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
