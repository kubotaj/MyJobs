//
//  ResultDetailViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "ResultDetailViewController.h"
#import "ResultURLViewController.h"

@interface ResultDetailViewController ()

@property (nonatomic) NSURL *url;
@property (nonatomic) Job *job;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *snippetLabel;


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
    
    NSString * temp = self.job.city;
    temp = [temp stringByAppendingString:@", "];
    temp = [temp stringByAppendingString:self.job.state];
    [self.locationLabel setText:temp];
    
    if (self.job.sourceType == 3 || self.job.sourceType == 1)
        [self.snippetLabel setText:self.job.snippet];
    
}

- (IBAction)didTapURLButton:(id)sender {
    ResultURLViewController *urlvController = [[ResultURLViewController alloc] initWithJob:self.job];
    
    [self.navigationController pushViewController: urlvController animated:YES];
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
