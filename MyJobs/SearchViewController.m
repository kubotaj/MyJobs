//
//  SearchViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsTableViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *jobTitle;
@property (weak, nonatomic) IBOutlet UITextField *jobLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
- (IBAction)searchButtonTapped:(UIButton *)sender;
- (void)findCurrentCity;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self findCurrentCity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    /* For testing */
    NSLog(@"Job Title is %@", self.jobTitle.text);
    NSLog(@"Job Location is %@", self.jobLocation.text);
    
    /* Generate the result lists. */
    NSString *urlString = [NSString stringWithFormat: @"http://www.cs.sonoma.edu/~jkubota/cs470s15/myJobs/myJobs.php?keyWord=%@&city=%@&state=%@", self.jobTitle, self.city, self.state];
    /* url should use "%20" for a white space. */
    urlString = [urlString stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
    /* Convert the string to url */
    NSURL *url = [NSURL URLWithString: urlString];
    /* Initialized the result view with url */
    SearchResultsTableViewController *rController = [[SearchResultsTableViewController alloc] initWithURL: url];
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
            self.jobLocation.text = self.city; // Pre-fill the jobLocation with current location.
        }
    }];
}

// Tells the delegate that the locaiton manager was unable to retrieve the location values.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

// Make the keyboard go away when "return" is pressed.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Make the keyboard go away when anywhere besides the text box is tapped.
- (IBAction) clickedBackground {
    
}


@end
