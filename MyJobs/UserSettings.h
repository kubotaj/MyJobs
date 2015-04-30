//
//  UserSettings.h
//  MyJobs
//
//  Created by student on 4/26/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (nonatomic) NSInteger searchRadius;
@property (nonatomic) NSInteger listingsMax;
@property (nonatomic) NSMutableArray *userSkills;
@property (nonatomic) NSString *preferredCity;

- (instancetype) initWithDefault;
- (void) setUserCity: (NSString *) city;

@end
