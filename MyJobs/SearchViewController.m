//
//  SearchViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *jobTitle;
@property (weak, nonatomic) IBOutlet UITextField *jobLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

- (IBAction)searchButtonTapped:(UIButton *)sender;
- (NSString *)getCurrentCity;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getCurrentCity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    NSLog(@"Job Title is %@", self.jobTitle.text);
    NSLog(@"Job Location is %@", self.jobLocation.text);
}

- (NSString *)getCurrentCity {
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

    
    return @"hello";
}

// Tells the delegate that new location data is available.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@", [locations lastObject]);
    self.location = [locations lastObject];
}

// Tells the delegate that the locaiton manager was unable to retrieve the location values.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
