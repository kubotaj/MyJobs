//
//  SignUpViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/26/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoMini.png"]];
    self.signUpView.logo = logoView; // logo can be any UIView
    
    // Change "Additional" to match our use
    [self.signUpView.additionalField setPlaceholder:@"Phone number"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Move all fields down on smaller screen sizes
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    [self.signUpView.logo setFrame:CGRectMake(120.0f, 70.0f, 150.0f, 150.0f)];
    [self.signUpView.usernameField setFrame:CGRectMake(55.0f, 250.0f, 250.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(55.0f, 300.0f, 250.0f, 50.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(55.0f, 350.0f, 250.0f, 50.0f)];
    [self.signUpView.additionalField setFrame:CGRectMake(55.0f, 400.0f, 250.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(55.0f, 500.0f, 250.0f, 40.0f)];
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
