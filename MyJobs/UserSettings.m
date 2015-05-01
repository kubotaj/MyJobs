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
    
    self.searchRadius = 40;
    self.listingsMax = 50;
    
    self.preferredCity = @"";
    self.userSkills = [[NSMutableArray alloc] init];
    
    self.skillCount = (int)[self.userSkills count];
    
    return self;
}

- (void) setUserCity: (NSString *) city{
    NSLog(@"Setting user city as: %@", city);
    self.preferredCity = [[city lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (int) findScoreMax{
    int maxScore = 0;
    
    //for recent listing
    maxScore += 3;
    
    //for same city
    maxScore += 2;
    
    //for skills
    for (int i = self.skillCount; i > 0; i--){
        maxScore += i;
    }
    
    return maxScore;
}

-(void) addSkill: (NSString *) skill {
    [self.userSkills addObject:skill];
    self.skillCount++;
}

-(void) clearSkills {
    [self.userSkills removeAllObjects];
}


@end
