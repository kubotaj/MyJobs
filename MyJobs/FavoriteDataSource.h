//
//  FavoriteDataSource.h
//  JobLink
//
//  Created by Joji Kubota on 5/3/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Job.h"

@interface FavoriteDataSource : NSObject

- (NSMutableArray *) getAllJobs;
- (NSInteger *) getNumberOfJobs;
- (Job *) jobAtIndex: (NSInteger *) idx;

@end
