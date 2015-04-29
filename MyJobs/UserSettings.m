//
//  UserSettings.m
//  MyJobs
//
//  Created by student on 4/26/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

-(instancetype) initWithDefault {
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    
    self.searchRadius = 30;
    self.listingsMax = 100;
    
    self.userSkills = [[NSMutableArray alloc] initWithObjects:@"ios", @"objective-c", @"mobile", nil];
    
    return self;
}

@end
