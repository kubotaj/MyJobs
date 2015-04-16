//
//  SearchResultsTableViewController.h
//  MyJobs
//
//  Created by Joji Kubota on 4/12/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndeedAPIDataSource.h"

@interface SearchResultsTableViewController : UITableViewController

- (id) initWithDataSource: (IndeedAPIDataSource *) dataSource;

@end
