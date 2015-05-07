//
//  IndeedJobs.h
//  MyJobs
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/15/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Job : NSObject

/* ensure property names match the XML element names */
@property (nonatomic) int sourceType;

@property (nonatomic) NSString *jobtitle;
@property (nonatomic) NSString *company;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *snippet;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *formattedRelativeTime;

@property (nonatomic) NSDate *datePosted;

@property (nonatomic) bool isFav;
@property (nonatomic) int score;
@property (nonatomic) NSMutableArray *skillsList; // Only used by CareerBuilder jobs

+ (NSString *) convertMonthtoNum: (NSString *) date;
- (void) convertDatePostedToFormattedRelativeTime;
- (void) toString;

@end
