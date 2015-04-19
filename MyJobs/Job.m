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

+ (NSString *) convertMonthtoNum: (NSString *) date{
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

@end
