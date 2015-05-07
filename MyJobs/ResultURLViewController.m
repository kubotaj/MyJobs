//
//  ResultURLViewController.m
//  JobLink
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/29/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "ResultURLViewController.h"

@interface ResultURLViewController ()

@property (nonatomic) NSURL *url;

@end

@implementation ResultURLViewController

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
    wv.delegate = (id<UIWebViewDelegate>)self;
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

@end
