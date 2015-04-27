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


@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *jobTitle;
@property (weak, nonatomic) IBOutlet UITextField *jobCity;
@property (weak, nonatomic) IBOutlet UITextField *jobState;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic) NSString *city;
@property (weak, nonatomic) NSString *state;
@property (nonatomic) int sortType;
@property (nonatomic) UserSettings *us;
- (IBAction)searchButtonTapped:(UIButton *)sender;
- (void)findCurrentCity;

@end

@implementation SearchViewController
- (instancetype) initWithSettings:(UserSettings *)us {
    if( (self = [super init]) == nil )
        return nil;
    
    self.us = us;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self findCurrentCity];
    self.sortType = 4; // sortType: 1 (jobTitle alpha), 2 (company alpha), 3 (most recent), 4 (most relevant)

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    /* For testing */
//    NSLog(@"Job Title is %@", self.jobTitle.text);
//    NSLog(@"Job City is %@", self.jobCity.text);
//    NSLog(@"Job City is %@", self.jobState.text);
    
    /* Generate the result lists. */
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
        [dataSourceIndeed filterJobs:self.us.userSkills];
    
        [allJobs addObjectsFromArray:indeedJobs];
    }
    
    /* CAREERBUILDER */
    NSString *urlStringCareerBuilder = [NSString stringWithFormat: @"http://api.careerbuilder.com/v2/jobsearch?DeveloperKey=WD907SX6B03NBR730Q7H&Keywords=%@&Location=%@, %@&Radius=%d&PerPage=%d", self.jobTitle.text, self.jobCity.text, self.jobState.text, (int)self.us.searchRadius, (int)self.us.listingsMax];
    urlStringCareerBuilder = [urlStringCareerBuilder stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
    NSLog(@"cb url: %@", urlStringCareerBuilder);
    CareerBuilderAPIDataSource *dataSourceCareerBuilder = [[CareerBuilderAPIDataSource alloc] initWithURLString: urlStringCareerBuilder];
    // filter jobs with score metric
    [dataSourceCareerBuilder filterJobs:self.us.userSkills];
    NSMutableArray *cbJobs = [dataSourceCareerBuilder getAllJobs];
    
    /* MONSTER */
    NSString *urlStringMonster = [NSString stringWithFormat: @"http://rss.jobsearch.monster.com/rssquery.ashx?brd=1&q=%@&cy=us&where=%@&where=%@&rad=%drad_units=miles&baseurl=jobview.monster.com#", self.jobTitle.text, self.jobCity.text, self.jobState.text, (int)self.us.searchRadius];
    NSLog(@"monster url: %@", urlStringMonster);
    urlStringMonster = [urlStringMonster stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    MonsterDataSource *dataSourceMonster = [[MonsterDataSource alloc] initWithURLString: urlStringMonster];
    NSMutableArray *mJobs = [dataSourceMonster getAllJobs];
    [dataSourceMonster filterJobs:self.us.userSkills];
    
    [allJobs addObjectsFromArray:cbJobs];
    [allJobs addObjectsFromArray:mJobs];
    
    NSMutableArray *sortedJobs = [[NSMutableArray alloc] init];
    
    switch (self.sortType) {
        case 0:
            sortedJobs = allJobs;
            break;
            
        case 1:
            sortedJobs = [allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j1, Job *j2){
                return [j1.jobtitle compare:j2.jobtitle];
            }];
            break;
            
        case 2:
            sortedJobs = [allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j1, Job *j2){
                return [j1.company compare:j2.company];
            }];
            break;
            
        case 3:
            sortedJobs = [allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j2, Job *j1){
                return [j1.datePosted compare:j2.datePosted];
            }];
            break;
            
        case 4:
            sortedJobs = [allJobs sortedArrayUsingComparator:^NSComparisonResult(Job *j1, Job *j2){
                return (j1.score < j2.score);
            }];
            
        default:
            break;
    }

    SearchResultsTableViewController *rController = [[SearchResultsTableViewController alloc] initWithJobsArray:sortedJobs];
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

// Make the keyboard go away when "return" is pressed.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Make the keyboard go away when anywhere besides the text box is tapped.
- (IBAction) clickedBackground {
    
}


@end
