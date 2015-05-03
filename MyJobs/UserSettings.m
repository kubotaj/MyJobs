//
//  UserSettings.m
//  MyJobs
//
//  Created by student on 4/26/15.
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
    NSLog(@"MADE IT2: %@", [PFUser currentUser].objectId);
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
    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSLog(@"len: %lu", (unsigned long)[objects count]);
//        if (!error) {
//            NSLog(@"MADE IT3: %lu", (unsigned long)[objects count]);
//            PFObject *object = [objects objectAtIndex:0];
//            self.searchRadius = [[object objectForKey:@"Radius"] integerValue];
//            if (! [[object objectForKey:@"Skill1"] isEqual:@""])
//                [self addSkill:[object objectForKey:@"Skill1"]];
//            if (! [[object objectForKey:@"Skill2"] isEqual:@""])
//                [self addSkill:[object objectForKey:@"Skill2"]];
//            if (! [[object objectForKey:@"Skill3"] isEqual:@""])
//                [self addSkill:[object objectForKey:@"Skill3"]];
//        } else {
//            NSLog(@"Error1: %@ %@", error, [error userInfo]);
//        }
//        NSLog(@"END");
//    }];
    NSLog(@"EXIT");
}


@end
