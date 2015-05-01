//
//  SettingsViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

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
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad called");
    [self updateUserSettings];
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
    [self updateUserSettings];
    NSLog(@"viewDidAppear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateUserSettings { //fills in text fields from the current user's settings.
    [self.currUserSettings clearSkills];
    self.currUser = [PFUser currentUser];
    //self.currUserSettings = [[UserSettings alloc] initWithDefault];
    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
    [query whereKey:@"userId" equalTo:self.currUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *obj = [objects objectAtIndex:0];
            self.currUserSettings.searchRadius = [[obj objectForKey:@"Radius"] intValue];
            [self.currUserSettings addSkill:[obj objectForKey:@"Skill1"]];
            [self.currUserSettings addSkill:[obj objectForKey:@"Skill2"]];
            [self.currUserSettings addSkill:[obj objectForKey:@"Skill3"]];
            
            self.searchRadius.text = [NSString stringWithFormat:@"%li", (long)self.currUserSettings.searchRadius];
            self.skill1.text = [self.currUserSettings.userSkills objectAtIndex:0];
            self.skill2.text = [self.currUserSettings.userSkills objectAtIndex:1];
            self.skill3.text = [self.currUserSettings.userSkills objectAtIndex:2];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)didTapUpdate:(id)sender {
    
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
