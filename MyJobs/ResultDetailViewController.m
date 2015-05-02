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
        [self.favoritedSwitch setOn:true];
    else
        [self.favoritedSwitch setOn:false];
    
}

- (IBAction)didTapURLButton:(id)sender {
    ResultURLViewController *urlvController = [[ResultURLViewController alloc] initWithJob:self.job];
    
    [self.navigationController pushViewController: urlvController animated:YES];
}

- (IBAction)didChangeFavoriteSwitch:(id)sender {
    if (!self.favoritedSwitch.on){
        [self.favoritedSwitch setOn:true animated:true];
        self.job.isFav = true;
    }
    else{
        [self.favoritedSwitch setOn:false animated:true];
        self.job.isFav = false;
    }
    NSLog(@"switch setting: %d", self.favoritedSwitch.on);
    NSLog(@"job's setting:  %d", self.job.isFav);
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
