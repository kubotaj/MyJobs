//
//  UserSettings.m
//  MyJobs
//
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/26/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "UserSettings.h"
#import <Parse/Parse.h>

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
    //NSLog(@"skillCount: %i", self.skillCount);
    int maxScore = 0;
    
    //for recent listing
    maxScore += 3;
    
    //for same city
    maxScore += 2;
    
    //for skills
    for (int i = 0; i < self.skillCount; i++){
        maxScore += 2;
    }
    
    return maxScore;
}

-(void) addSkill: (NSString *) skill {
    [self.userSkills addObject:skill];
    self.skillCount++;
}

-(void) clearSkills {
    self.skillCount = 0;
    [self.userSkills removeAllObjects];
}

-(void) updateUserSettings {

    [self clearSkills];
    
    NSString *currUserId = [PFUser currentUser].objectId;
    PFQuery *query = [PFQuery queryWithClassName:@"UserSettings"];
    [query whereKey:@"userId" equalTo:currUserId];
    PFObject *object = [query getFirstObject];
    self.searchRadius = [[object objectForKey:@"Radius"] integerValue];
    if (! [[object objectForKey:@"Skill1"] isEqual:@""])
        [self addSkill:[object objectForKey:@"Skill1"]];
    if (! [[object objectForKey:@"Skill2"] isEqual:@""])
        [self addSkill:[object objectForKey:@"Skill2"]];
    if (! [[object objectForKey:@"Skill3"] isEqual:@""])
        [self addSkill:[object objectForKey:@"Skill3"]];
}


@end
