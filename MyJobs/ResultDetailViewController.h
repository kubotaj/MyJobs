//
//  ResultDetailViewController.h
//  MyJobs
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SearchResultsTableViewController.h"
#import "Job.h"

@interface ResultDetailViewController : UIViewController

- (id) initWithJob: (Job *) job;

@end
