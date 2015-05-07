//
//  SearchResultsTableViewController.h
//  MyJobs
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/12/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"

@interface SearchResultsTableViewController : UITableViewController

- (id) initWithJobsArray: (NSMutableArray *) jobsArray andSettings: (UserSettings *) us;

@end
