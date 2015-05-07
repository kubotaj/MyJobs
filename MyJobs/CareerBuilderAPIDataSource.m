//
//  CareerBuilderAPIDataSource.m
//  MyJobs
//  
//  Created by Joji Kubota, Kenji Johnson & Jeff Teller on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "CareerBuilderAPIDataSource.h"

@interface CareerBuilderAPIDataSource()

@property (nonatomic) NSString *cbURLString;
@property (nonatomic) Job *cbJob;
@property (nonatomic) NSMutableArray *jobs;
@property (nonatomic) NSString *currentElement;
@property (nonatomic) NSMutableString *currentElementValue;
@property (nonatomic) NSString *locationSave;

@end

@implementation CareerBuilderAPIDataSource

-(instancetype) initWithURLString: (NSString *) urlString{
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    self.locationSave = [[NSString alloc] init];
    // Setup the parser
    self.cbURLString = urlString;
    NSURL *url = [NSURL URLWithString: self.cbURLString];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = (id<NSXMLParserDelegate>)self;
    // Start parsing
    BOOL success = [parser parse];
    // Verification.
    if (success) {
        NSLog(@"No errors - result count : %i", (int)[self.jobs count]);
    }
    else {
        NSLog(@"Error parsing document!");
    }
    
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //NSLog(@"Start CB parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parsing error");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"Element[%@]found", elementName);
    
    /* Create a new instance of Job */
    if ([elementName isEqualToString: @"JobSearchResult"]) {
        self.cbJob = [[Job alloc] init];
        self.cbJob.skillsList = [[NSMutableArray alloc] init];
        self.cbJob.sourceType = 2;
        self.cbJob.score = 1;
        self.cbJob.isFav = false;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //NSLog(@"String[%@]found", string);
    
    if (!self.currentElementValue) {
        self.currentElementValue = [[NSMutableString alloc] initWithString: string];
    }
    else {
        [self.currentElementValue appendString: string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //NSLog(@"Element[%@]finished", elementName);
    
    // We reached the end of the XML document
    if ([elementName isEqualToString: @"Results"]) {
        return;
    }
    
    if ([elementName isEqualToString:@"JobSearchResult"]) {
        // End of one result. Add it to the array.
        if (!self.jobs) {
            self.jobs = [[NSMutableArray alloc] init];
        }
        [self.jobs addObject: self.cbJob];
        //NSLog(@"%@", self.cbJob.skillsList);
        // release object
        self.cbJob = nil;
    }
    else if ([elementName isEqualToString: @"JobTitle"] ||
             [elementName isEqualToString: @"Company"] ||
             [elementName isEqualToString: @"Location"] ||
             [elementName isEqualToString: @"City"] ||
             [elementName isEqualToString: @"State"] ||
             [elementName isEqualToString: @"DescriptionTeaser"] ||
             [elementName isEqualToString: @"JobDetailsURL"] ||
             [elementName isEqualToString: @"PostedTime"] ||
             [elementName isEqualToString: @"Skill"]) {
        
        // Get ride of the weired newline chars and whitespace!
        self.currentElementValue = (NSMutableString*)[self.currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.currentElementValue = (NSMutableString*)[self.currentElementValue stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
        
        if ([elementName isEqualToString: @"JobTitle"])
            [self.cbJob setValue: self.currentElementValue forKey: @"jobtitle"];
        if ([elementName isEqualToString: @"Company"])
            [self.cbJob setValue: self.currentElementValue forKey: @"company"];
        if ([elementName isEqualToString: @"Location"])
            self.locationSave = self.currentElementValue;
        if ([elementName isEqualToString: @"City"])
            [self.cbJob setValue: self.currentElementValue forKey: @"city"];
        if ([elementName isEqualToString: @"State"]){
            [self.cbJob setValue: self.currentElementValue forKey: @"state"];
            if ([self.cbJob.city isEqualToString:@""] && [self.cbJob.state isEqualToString:@""])
                [self.cbJob setValue:self.locationSave forKey:@"city"];
        }
        if ([elementName isEqualToString: @"DescriptionTeaser"])
            [self.cbJob setValue: self.currentElementValue forKey: @"snippet"];
        if ([elementName isEqualToString: @"JobDetailsURL"])
            [self.cbJob setValue: self.currentElementValue forKey: @"url"];
        if ([elementName isEqualToString: @"PostedTime"]){
            //create NSDate from ex. "3/27/2015 8:55:29 AM"
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [formatter setTimeZone:gmt];
            [self.cbJob setValue:[formatter dateFromString:self.currentElementValue] forKey:@"datePosted"];
            [self.cbJob convertDatePostedToFormattedRelativeTime];
        }
        if ([elementName isEqualToString: @"Skill"])
            [self.cbJob.skillsList addObject:[self.currentElementValue lowercaseString]];
    }
    
    // Reset the variable.
    self.currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"Parsing CB finished");

}

- (void) filterJobs:(UserSettings *)userSettings{
    NSMutableArray *userSkills = userSettings.userSkills;
    for (Job *j in self.jobs){
        // Compare skills
        for (NSString *userSkill in userSkills){
            bool found = false;
            NSMutableArray *jobTitleWords = (NSMutableArray *)[j.jobtitle componentsSeparatedByString:@" "];
            for (NSString *word in jobTitleWords){
                NSString *reformattedWord = [[word lowercaseString] stringByReplacingOccurrencesOfString:@"," withString:@""];
                if ([reformattedWord isEqualToString:userSkill] && !found){
                    j.score += 2;
                    found = true;
                }
            }
            for (NSString *jobSkill in j.skillsList){
                NSMutableArray *words = (NSMutableArray *)[jobSkill componentsSeparatedByString:@" "];
                for (NSString *word in words){
                    if ([word isEqualToString:userSkill] && !found){
                        j.score += 2;
                        found = true;
                    }
                }
            }
        }
        // In the right city?
        if ([userSettings.preferredCity isEqualToString:[[j.city lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]]){
            j.score += 2;
        }
        // Filter out CyberCoders
        if ([j.company isEqualToString:@"CyberCoders"])
            j.score -= 3;
        // How recent is the listing
        NSTimeInterval relativeTimeSeconds;
        relativeTimeSeconds = [[NSDate date]timeIntervalSinceDate: j.datePosted]; //seconds since job posted
        if (relativeTimeSeconds < 86400){       // Is this posting less than a day old
            j.score += 3;
        }
        else if (relativeTimeSeconds < 604800){ // Is this posting less than a week old
            j.score += 1;
        }
        //if (j.score > 1) NSLog(@"Final job score = %d", j.score);
    }
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

+ (int) roundRadiusforCB: (int) rIn{
    int rOut;
    //5, 10, 20, 30, 50, 100, or 150
    if (rIn < 6)
        rOut = 5;
    else if (rIn > 5 && rIn < 16)
        rOut = 10;
    else if (rIn > 15 && rIn < 26)
        rOut = 20;
    else if (rIn > 25 && rIn < 41)
        rOut = 30;
    else if (rIn > 40 && rIn < 76)
        rOut = 50;
    else if (rIn > 75 && rIn < 126)
        rOut = 100;
    else
        rOut = 150;
    return rOut;
}

@end