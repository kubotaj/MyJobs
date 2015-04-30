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
@property (weak, nonatomic) PFObject *currUserSettings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad called");
    self.currUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
    [query whereKey:@"userId" equalTo:self.currUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
