//
//  FavoriteDataSource.m
//  JobLink
//
//  Created by Joji Kubota on 5/3/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "FavoriteDataSource.h"

@interface FavoriteDataSource()

@property (nonatomic) NSArray *parseJobs;
@property (nonatomic) NSMutableArray *jobs;


@end

@implementation FavoriteDataSource

-(instancetype) init {
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    /* Initialize the arrays. */
    self.jobs = [[NSMutableArray alloc] init];
    self.parseJobs = [[NSArray alloc] init];
    
    /* Pull the favorites from Parse for the user */
    PFQuery *query = [PFQuery queryWithClassName:@"FavJobs"];
    if (query) {
        if ([PFUser currentUser]) {
            NSString *username = [PFUser currentUser].username;
            [query whereKey:@"user" equalTo:username];
            [query orderByDescending:@"createdAt"];
            self.parseJobs = [query findObjects];
        }
    }
    
    /* Save back the data into Job object */
    for (PFObject *job in self.parseJobs) {
        Job *aJob = [[Job alloc] init];
        aJob.jobtitle = job[@"jobtitle"];
        aJob.company = job[@"company"];
        aJob.city = job[@"city"];
        aJob.state = job[@"state"];
        aJob.snippet = job[@"snippet"];
        aJob.url = job[@"url"];
        aJob.formattedRelativeTime = job[@"formattedRelativeTime"];
        aJob.datePosted = job[@"datePosted"];
        aJob.isFav = job[@"isFav"];
        aJob.score = [job[@"score"] intValue];
//        self.aJob.skillsList = job[@"skillsList"];
        aJob.sourceType = [job[@"sourceType"] intValue];
        [self.jobs addObject:aJob];
    }
    
    NSLog(@"size of the favoriteDataSource is %d", [self.jobs count]);
    
    return self;
}

- (NSMutableArray *) getAllJobs {
    return self.jobs;
}

- (NSInteger *) getNumberOfJobs {
    return (NSInteger *)[self.jobs count];
}

- (Job *) jobAtIndex: (NSInteger *) idx {
    if( idx >= (NSInteger *)[self.jobs count] )
        return nil;
    
    return [self.jobs objectAtIndex: (int)idx];
}

@end
