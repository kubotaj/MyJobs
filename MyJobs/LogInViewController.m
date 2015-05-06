//
//  LogInViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/26/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JLLogo.png"]];
    
    self.logInView.logo = logoView; // logo can be any UIView
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake(120.0f, 70.0f, 150.0f, 150.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(55.0f, 250.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(55.0f, 300.0f, 250.0f, 50.0f)];
    [self.logInView.passwordForgottenButton setFrame: CGRectMake(55.0f, 350.0f, 250.0f, 50.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(55.0f, 400.0f, 250.0f, 40.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(55.0f, 500.0f, 250.0f, 40.0f)];
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
