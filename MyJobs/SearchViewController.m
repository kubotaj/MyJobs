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

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *jobTitle;
@property (weak, nonatomic) IBOutlet UITextField *jobCity;
@property (weak, nonatomic) IBOutlet UITextField *jobState;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
- (NSComparisonResult)compareJob: (id) element with: (id) element2;
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

//- (NSComparisonResult)compareJob: (id) element with: (id) element2 {
//    return [[element jobtitle] compare: [element2 jobtitle]];
//}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    /* For testing */
//    NSLog(@"Job Title is %@", self.jobTitle.text);
//    NSLog(@"Job City is %@", self.jobCity.text);
//    NSLog(@"Job City is %@", self.jobState.text);
    
    /* Generate the result lists. */
    
    /* INDEED */
    //NSString *urlString = [NSString stringWithFormat: @"http://www.cs.sonoma.edu/~jkubota/cs470s15/myJobs/indeedAPI.php?keyWord=%@&city=%@&state=%@", self.jobTitle.text, self.jobCity.text, self.jobState.text];
    NSString *urlStringIndeed = [NSString stringWithFormat: @"http://api.indeed.com/ads/apisearch?publisher=5703933454627100&q=%@&l=%@,+%@&sort=&radius=&st=&jt=&start=&limit=25&fromage=&filter=&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla//4.0(Firefox)&v=2", self.jobTitle.text, self.jobCity.text, self.jobState.text];
    // url should use "%20" for a white space.
    urlStringIndeed = [urlStringIndeed stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
    // Initialized the result view with url
    IndeedAPIDataSource *dataSourceIndeed = [[IndeedAPIDataSource alloc] initWithURLString: urlStringIndeed];
    NSMutableArray *indeedJobs = [dataSourceIndeed getAllJobs];
    
    /* CAREERBUILDER */
    NSString *urlStringCareerBuilder = [NSString stringWithFormat: @"http://api.careerbuilder.com/v1/jobsearch?DeveloperKey=WD907SX6B03NBR730Q7H&Keywords=%@&Location=%@, %@", self.jobTitle.text, self.jobCity.text, self.jobState.text];
    // url should use "%20" for a white space.
    urlStringCareerBuilder = [urlStringCareerBuilder stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
    NSLog(@"cb url: %@", urlStringCareerBuilder);
    // Initialized the result view with url
    CareerBuilderAPIDataSource *dataSourceCareerBuilder = [[CareerBuilderAPIDataSource alloc] initWithURLString: urlStringCareerBuilder];
    NSMutableArray *cbJobs = [dataSourceCareerBuilder getAllJobs];
    
    /* MONSTER */
    NSString *urlStringMonster = [NSString stringWithFormat: @"http://rss.jobsearch.monster.com/rssquery.ashx?brd=1&q=%@&cy=us&where=%@&where=%@&rad=30rad_units=miles&baseurl=jobview.monster.com#", self.jobTitle.text, self.jobCity.text, self.jobState.text];
    NSLog(@"monster url: %@", urlStringMonster);
    urlStringMonster = [urlStringMonster stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    MonsterDataSource *dataSourceMonster = [[MonsterDataSource alloc] initWithURLString: urlStringMonster];
    NSMutableArray *mJobs = [dataSourceMonster getAllJobs];
    
    NSMutableArray *allJobs = [[NSMutableArray alloc] init];
    
    [allJobs addObjectsFromArray:indeedJobs];
    [allJobs addObjectsFromArray:cbJobs];
    [allJobs addObjectsFromArray:mJobs];
    
    //[allJobs sortUsingSelector:@selector(compareJob:with:)];
    
    // Need to get results from all data sources before pushing to table view
    //SearchResultsTableViewController *rController = [[SearchResultsTableViewController alloc] initWithDataSource: dataSourceIndeed];
    SearchResultsTableViewController *rController = [[SearchResultsTableViewController alloc] initWithJobsArray:allJobs];
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
