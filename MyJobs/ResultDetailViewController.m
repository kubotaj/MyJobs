//
//  ResultDetailViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "ResultDetailViewController.h"
#import "ResultURLViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ResultDetailViewController ()

@property (nonatomic) NSURL *url;
@property (nonatomic) Job *job;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *snippetLabel;
@property (weak, nonatomic) IBOutlet UILabel *postingTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *favoritedSwitch;
@property (weak, nonatomic) IBOutlet UIButton *URLButton;


@end

@implementation ResultDetailViewController

- (id) initWithJob: (Job *) job {
    self.job = job;
    NSLog(@"url: %@", job.url);
    self.url = [NSURL URLWithString: job.url];
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.jobTitleLabel setText:self.job.jobtitle];
    [self.companyLabel setText:self.job.company];
    
    NSString * locationText = self.job.city;
    locationText = [locationText stringByAppendingString:@", "];
    locationText = [locationText stringByAppendingString:self.job.state];
    [self.locationLabel setText:locationText];
    
    if (self.job.sourceType == 3 || self.job.sourceType == 1)
        [self.snippetLabel setText:self.job.snippet];
    
    if (self.job.sourceType == 2){
        NSString * skillsTextList = @"Skills: ";
        skillsTextList = [skillsTextList stringByAppendingString:[self.job.skillsList componentsJoinedByString: @", "]];
        [self.snippetLabel setText:skillsTextList];
    }
    
    NSString *timeText = @"Posted ";
    timeText = [timeText stringByAppendingString:self.job.formattedRelativeTime];
    [self.postingTimeLabel setText:timeText];
    
    self.URLButton.layer.cornerRadius = 10;
    self.URLButton.clipsToBounds = true;
    
    if (self.job.isFav)
        [self.favoritedSwitch setOn:YES];
    else
        [self.favoritedSwitch setOn:NO];
    NSLog(@"Initial switch state %d", [self.favoritedSwitch isOn]);
}

- (IBAction)didTapURLButton:(id)sender {
    ResultURLViewController *urlvController = [[ResultURLViewController alloc] initWithJob:self.job];
    
    [self.navigationController pushViewController: urlvController animated:YES];
}

- (IBAction)didChangeFavoriteSwitch:(id)sender {
    
    if ([sender isOn]){
        NSLog(@"you were turned ON");
        self.job.isFav = true;
    }
    else{
        NSLog(@"you were turned OFF");
        self.job.isFav = false;
    }
    
    NSLog(@"switch setting: %d", [sender isOn]);
    NSLog(@"job's setting:  %d", self.job.isFav);
}

- (void) viewWillDisappear:(BOOL)animated {
    PFObject *favJob = [PFObject objectWithClassName:@"FavJobs"];
    PFQuery *query = [PFQuery queryWithClassName:@"FavJobs"];
    NSString *username = [PFUser currentUser].username;
    NSString *jobtitle = self.job.jobtitle;
    NSString *company = self.job.company;
    NSString *city = self.job.city;
    [query whereKey:@"user" equalTo:username];
    [query whereKey:@"jobtitle" equalTo:jobtitle];
    [query whereKey:@"company" equalTo:company];
    [query whereKey:@"city" equalTo:city];
    [query orderByDescending:@"createdAt"];
    
    /* Save the job info in parse if it's a favorite */
    if (self.job.isFav) {
        // Make a if statemenent to avoid creating duplicates.
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                NSLog(@"Job in Favorite");
            }
            else {
                NSLog(@"Job not in Favorite yet");
                favJob[@"user"] = [PFUser currentUser].username;
                favJob[@"jobtitle"] = self.job.jobtitle;
                favJob[@"company"] = self.job.company;
                favJob[@"city"] = self.job.city;
                favJob[@"state"] = self.job.state;
                favJob[@"snippet"] = self.job.snippet;
                favJob[@"url"] = self.job.url;
                favJob[@"formattedRelativeTime"] = self.job.formattedRelativeTime;
                favJob[@"datePosted"] = self.job.datePosted;
                favJob[@"isFav"] = @(self.job.isFav).stringValue;
                favJob[@"score"] = @(self.job.score).stringValue;
                favJob[@"skillsList"] = self.job.skillsList;
                
                [favJob save];

            }
        }];

    }

    else {
        // Add code to delete object if it exits in the database.
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                NSLog(@"Job in Favorite");
                [object deleteInBackgroundWithBlock:^(BOOL success, NSError *error) {
                    if (!error) {
                        NSLog(@"Deleted successfully.");
                    }
                    else {
                        NSLog(@"Error at Delete: %@", error);
                    }
                }];
            }
            else {
                NSLog(@"Job not in Favorite yet");
            }
        }];

    }

    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
