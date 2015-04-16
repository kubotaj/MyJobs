//
//  IndeedAPIDataSource.h
//  MyJobs
//
//  Created by Joji Kubota on 4/15/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndeedJob.h"

@interface IndeedAPIDataSource : NSObject

- (instancetype) initWithURLString: (NSString *) urlString;
- (NSMutableArray *) getAllJobs;
- (NSInteger *) getNumberOfJobs;
- (IndeedJob *) jobAtIndex: (NSInteger *) idx;

@end

