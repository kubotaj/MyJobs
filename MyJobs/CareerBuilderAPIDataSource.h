//
//  CareerBuilderAPIDataSource.h
//  MyJobs
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Job.h"
#import "UserSettings.h"

@interface CareerBuilderAPIDataSource : NSObject

- (instancetype) initWithURLString: (NSString *) urlString;
- (NSMutableArray *) getAllJobs;
- (NSInteger *) getNumberOfJobs;
- (Job *) jobAtIndex: (NSInteger *) idx;
- (void) filterJobs: (UserSettings *) userSettings;

+ (int) roundRadiusforCB: (int) rIn;

@end
