//
//  SearchViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsTableViewController.h"
#import "IndeedAPIDataSource.h"
#import "CareerBuilderAPIDataSource.h"
#import "MonsterDataSource.h"
#import "UserSettings.h"
#import "LogInViewController.h"
#import "SignUpViewController.h"



@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *jobTitle;
@property (weak, nonatomic) IBOutlet UITextField *jobCity;
@property (weak, nonatomic) IBOutlet UITextField *jobState;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic) NSString *city;
@property (weak, nonatomic) NSString *state;
@property (nonatomic) UserSettings *us;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (nonatomic) PFObject *prevSearch;
- (IBAction)searchButtonTapped:(UIButton *)sender;
- (IBAction)logoutButtonTapped:(id)sender;
- (void)findCurrentCity;

@end

@implementation SearchViewController
- (instancetype) initWithSettings:(UserSettings *)us {
    if( (self = [super init]) == nil )
        return nil;
    
    self.us = us;
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    /* Show who is logged in */
    if ([PFUser currentUser]) {
        self.loginLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Logged in as %@", nil), [[PFUser currentUser] username]];
    } else {
        self.loginLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Check if user is logged in
//    if (![[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue] ||
//        ![PFUser currentUser]
//        ) {
    if (![PFUser currentUser]) {
        // Create the log in view controller
        LogInViewController *logInViewController = [[LogInViewController alloc] init];
        logInViewController.delegate = self; // Set ourselves as the delegate
        
        // Create the sign up view controller
        // Customize the Sign Up View Controller
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
        logInViewController.signUpController = signUpViewController;
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:logInViewController.signUpController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

/* Delegate method when user logged in successfully */
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
//    if ([[user objectForKey:@"emailVerified"] boolValue]) {
//        [self viewDidLoad]; // Refresh the view with the user info.
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email not verified"
//                                                        message:@"You must verify your email address before logging in"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
    [self viewDidLoad]; // Refresh the view with the user info.
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Delegate method when user cancels the log in */
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

/* Delegate method when user signed up successfully */
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self viewDidLoad]; // Refresh the view
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PFUser *currUser = [PFUser currentUser]; //get current user
    NSLog(@"here");
    PFObject *userSettings = [PFObject objectWithClassName:@"UserSettings"];
    userSettings[@"userId"] = currUser.objectId;
    userSettings[@"Radius"] = @30;
    userSettings[@"Skill1"] = @"";
    userSettings[@"Skill2"] = @"";
    userSettings[@"Skill3"] = @"";
    [userSettings saveInBackground];
    NSLog(@"there");
    [self.tabBarController setSelectedIndex:2];
}

/* Delegate method when user cancels the signed up */
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (IBAction)logoutButtonTapped:(id)sender {
    [PFUser logOut];
    [self viewDidAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    /* Retrieve the search history based on the user account */
    if ([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"PrevSearch"];
        NSString *username = [PFUser currentUser].username;
        [query whereKey:@"user" equalTo:username];
        [query orderByDescending:@"createdAt"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *prevSearch, NSError *error) {
            if (!prevSearch) {
                NSLog(@"No search history found.");
                self.jobTitle.text = @""; // Clear the text field as there is no search history.
                [self findCurrentCity];
            } else {
                // The find succeeded.
                NSLog(@"Successfully retrieved the most recent search history.");
                self.jobTitle.text = prevSearch[@"jobTitle"];
                self.jobCity.text = prevSearch[@"jobCity"];
                self.jobState.text = prevSearch[@"jobState"];
            }
        }];
    }
    
    /* Register observers for the keyboard notification. */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewDidUnload {
    /* Unload the keyboard observers. */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.theScrollView = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    
    /* Delete previous search history from the database */
    PFQuery *query = [PFQuery queryWithClassName:@"PrevSearch"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects)
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                        NSLog(@"deleted prev search");
                }];
        } else
            NSLog(@"Error: %@ %@", error, [error userInfo]);
    }];

    /* Add the search history to the database */
    self.prevSearch = [PFObject objectWithClassName:@"PrevSearch"];
    self.prevSearch[@"user"] = [PFUser currentUser].username;
    self.prevSearch[@"jobTitle"] = self.jobTitle.text;
    self.prevSearch[@"jobCity"] = self.jobCity.text;
    self.prevSearch[@"jobState"] = self.jobState.text;
    [self.prevSearch save];
    
    /* Generate the result lists. */
    [self.us setUserCity:self.jobCity.text];
    NSMutableArray *allJobs = [[NSMutableArray alloc] init];
    
    /* INDEED */
    for (int i = 0; i < self.us.listingsMax / 25; i++){
        NSString *urlStringIndeed = [NSString stringWithFormat: @"http://api.indeed.com/ads/apisearch?publisher=5703933454627100&q=%@&l=%@,+%@&sort=&radius=%d&limit=25&start=%d&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla//4.0(Firefox)&v=2", self.jobTitle.text, self.jobCity.text, self.jobState.text, (int)self.us.searchRadius, (i * 25)];
        // url should use "%20" for a white space.
        urlStringIndeed = [urlStringIndeed stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
        NSLog(@"indeed url: %@", urlStringIndeed);
        // Initialized the result view with url
        IndeedAPIDataSource *dataSourceIndeed = [[IndeedAPIDataSource alloc] initWithURLString: urlStringIndeed];
        NSMutableArray *indeedJobs = [dataSourceIndeed getAllJobs];
        [dataSourceIndeed filterJobs:self.us];
    
        [allJobs addObjectsFromArray:indeedJobs];
    }
    
    /* CAREERBUILDER */
    NSString *urlStringCareerBuilder = [NSString stringWithFormat: @"http://api.careerbuilder.com/v2/jobsearch?DeveloperKey=WD907SX6B03NBR730Q7H&Keywords=%@&Location=%@, %@&Radius=%d&PerPage=%d", self.jobTitle.text, self.jobCity.text, self.jobState.text, [CareerBuilderAPIDataSource roundRadiusforCB:((int)self.us.searchRadius)], (int)self.us.listingsMax];
    urlStringCareerBuilder = [urlStringCareerBuilder stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
    NSLog(@"cb url: %@", urlStringCareerBuilder);
    CareerBuilderAPIDataSource *dataSourceCareerBuilder = [[CareerBuilderAPIDataSource alloc] initWithURLString: urlStringCareerBuilder];
    // filter jobs with score metric
    [dataSourceCareerBuilder filterJobs:self.us];
    NSMutableArray *cbJobs = [dataSourceCareerBuilder getAllJobs];
    
    /* MONSTER */
    NSString *urlStringMonster = [NSString stringWithFormat: @"http://rss.jobsearch.monster.com/rssquery.ashx?brd=1&q=%@&cy=us&where=%@&where=%@&rad=%drad_units=miles&baseurl=jobview.monster.com#", self.jobTitle.text, self.jobCity.text, self.jobState.text, (int)self.us.searchRadius];
    NSLog(@"monster url: %@", urlStringMonster);
    urlStringMonster = [urlStringMonster stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    MonsterDataSource *dataSourceMonster = [[MonsterDataSource alloc] initWithURLString: urlStringMonster];
    NSMutableArray *mJobs = [dataSourceMonster getAllJobs];
    [dataSourceMonster filterJobs:self.us];
    
    [allJobs addObjectsFromArray:cbJobs];
    [allJobs addObjectsFromArray:mJobs];
    
    NSMutableArray *sortedJobs = [[NSMutableArray alloc] init];
    
    sortedJobs = (NSMutableArray *)[allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j1, Job *j2){
        if (j1.score < j2.score)
            return (j1.score < j2.score);
        else
            return [j2.datePosted compare:j2.datePosted];
    }];
    
    sortedJobs = (NSMutableArray *)[allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j1, Job *j2){
        if (j1.score == j2.score)
            return [j2.datePosted compare:j1.datePosted];
        else
            return (j1.score < j2.score);
    }];

    SearchResultsTableViewController *rController = [[SearchResultsTableViewController alloc] initWithJobsArray:sortedJobs andSettings:self.us];
    [self.navigationController pushViewController:rController animated:YES];

}


- (void)findCurrentCity {
    // Configure location manager.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    // Obtain the location values.
    [self.locationManager startUpdatingLocation];
}

// Tells the delegate that new location data is available.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Stop Location Manager
    [self.locationManager stopUpdatingLocation];

    // Retrieve the city info.
    self.location = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation: self.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            self.city = [placemark subAdministrativeArea];
            self.state = [placemark administrativeArea];
            NSLog(@"Current city is %@", self.city);
            NSLog(@"Current state is %@", self.state);
            self.jobCity.text = self.city; // Pre-fill the jobLocation with current location.
            self.jobState.text = self.state; // Pre-fill the jobLocation with current location.
        }
    }];
}

// Tells the delegate that the locaiton manager was unable to retrieve the location values.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.theScrollView.contentInset = contentInsets;
    self.theScrollView.scrollIndicatorInsets = contentInsets;
    
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextField.frame.origin.y - (keyboardSize.height-15));
        [self.theScrollView setContentOffset:scrollPoint animated:YES];

    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    NSLog(@"KeyboardWillHide");
//
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.theScrollView.contentInset = contentInsets;
//    çscrollIndicatorInsets = contentInsets;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 20.0f, 0.0, 0.0, 0.0);
    self.theScrollView.contentInset = contentInsets;
    self.theScrollView.scrollIndicatorInsets = contentInsets;
}

// Set activeTextField to the current active textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

// Set activeTextField to nil
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}


// Dismiss the keyboard
- (IBAction)dismissKeyboard:(id)sender {
    [self.activeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


@end
