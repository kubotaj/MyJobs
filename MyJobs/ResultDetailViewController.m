//
//  ResultDetailViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "ResultDetailViewController.h"

@interface ResultDetailViewController ()

@property (nonatomic) NSURL *url;

@end

@implementation ResultDetailViewController

- (id) initWithJob: (Job *) job {
    NSLog(@"url: %@", job.url);
    self.url = [NSURL URLWithString: job.url];
        
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the webview frame.
    UIWebView *wv = [[UIWebView alloc] initWithFrame: self.view.bounds];
    wv.delegate = self;
    wv.scalesPageToFit = YES;
    [self.view addSubview: wv];
    
    // Call the website.
    NSURLRequest *req = [NSURLRequest requestWithURL: self.url];
    [wv loadRequest: req];
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
