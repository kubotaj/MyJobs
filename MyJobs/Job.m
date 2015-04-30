//
//  IndeedJobs.m
//  MyJobs
//
//  Created by Joji Kubota on 4/15/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "Job.h"

@interface Job()

@end

@implementation Job

+ (NSString *) convertMonthtoNum: (NSString *) date {
    //NSLog(@"In converMonthtoNum: orig = %@", date);
    
    date = [date stringByReplacingOccurrencesOfString:@"Jan" withString:@"1"];
    date = [date stringByReplacingOccurrencesOfString:@"Feb" withString:@"2"];
    date = [date stringByReplacingOccurrencesOfString:@"Mar" withString:@"3"];
    date = [date stringByReplacingOccurrencesOfString:@"Apr" withString:@"4"];
    date = [date stringByReplacingOccurrencesOfString:@"May" withString:@"5"];
    date = [date stringByReplacingOccurrencesOfString:@"Jun" withString:@"6"];
    date = [date stringByReplacingOccurrencesOfString:@"Jul" withString:@"7"];
    date = [date stringByReplacingOccurrencesOfString:@"Aug" withString:@"8"];
    date = [date stringByReplacingOccurrencesOfString:@"Sep" withString:@"9"];
    date = [date stringByReplacingOccurrencesOfString:@"Oct" withString:@"10"];
    date = [date stringByReplacingOccurrencesOfString:@"Nov" withString:@"11"];
    date = [date stringByReplacingOccurrencesOfString:@"Dec" withString:@"12"];
    
    date = [date stringByReplacingOccurrencesOfString:@" GMT" withString:@""];
    
    //NSLog(@"In converMonthtoNum: done = %@", date);
    return date;
}

-(void) convertDatePostedToFormattedRelativeTime {
    NSTimeInterval relativeTimeSeconds, relativeTimeHours;
    relativeTimeSeconds = [[NSDate date]timeIntervalSinceDate: self.datePosted]; //seconds since job posted
    relativeTimeHours = relativeTimeSeconds / 3600; //convert to hours
    relativeTimeHours = floor(relativeTimeHours);
    NSInteger relativeTime = relativeTimeHours / 24; //cast to int
    //relativeTime = relativeTime / 24;
    if ( relativeTime < 1 ) {
        NSString *formattedRelativeTimeHours = [NSString stringWithFormat:@"%.0f hours ago", relativeTimeHours];
        self.formattedRelativeTime = formattedRelativeTimeHours;
    }
    else {
        if ( relativeTime > 1) {
            NSString *formattedRelativeTimeDays = [NSString stringWithFormat:@"%i days ago", (int)relativeTime];
            self.formattedRelativeTime = formattedRelativeTimeDays;
        }
        else {
            NSString *formattedRelativeTimeDays = [NSString stringWithFormat:@"%i day ago", (int)relativeTime];
            self.formattedRelativeTime = formattedRelativeTimeDays;
            
        }
    }
    //NSLog(@"relativeTime: %i", relativeTime2);
}

@end
