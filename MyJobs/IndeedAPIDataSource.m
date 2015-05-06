//
//  IndeedAPIDataSource.m
//  MyJobs
//
//  Created by Joji Kubota on 4/15/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "IndeedAPIDataSource.h"

@interface IndeedAPIDataSource()

@property (nonatomic) NSString *indeedURLString;
@property (nonatomic) Job *iJob;
@property (nonatomic) NSMutableArray *jobs;
@property (nonatomic) NSString *currentElement;
@property (nonatomic) NSMutableString *currentElementValue;

@end

@implementation IndeedAPIDataSource

-(instancetype) initWithURLString: (NSString *) urlString {
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    
    // Setup the parser
    self.indeedURLString = urlString;
    NSURL *url = [NSURL URLWithString: self.indeedURLString];
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
    NSLog(@"Start Indeed parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parsing error");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"Element[%@]found", elementName);
    
    /* Create a new instance of iJob */
    if ([elementName isEqualToString: @"result"]) {
        self.iJob = [[Job alloc] init];
        self.iJob.sourceType = 3;
        self.iJob.score = 1;
        self.iJob.isFav = false;
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
    if ([elementName isEqualToString: @"results"]) {
        return;
    }
    
    if ([elementName isEqualToString:@"result"]) {
        // End of one result. Add it to the array.
        if (!self.jobs) {
            self.jobs = [[NSMutableArray alloc] init];
        }
        [self.jobs addObject: self.iJob];
        // release object
        self.iJob = nil;
    }
    else if ([elementName isEqualToString: @"jobtitle"] ||
             [elementName isEqualToString: @"company"] ||
             [elementName isEqualToString: @"city"] ||
             [elementName isEqualToString: @"state"] ||
             [elementName isEqualToString: @"snippet"] ||
             [elementName isEqualToString: @"url"] ||
             [elementName isEqualToString: @"formattedRelativeTime"] ||
             [elementName isEqualToString: @"date"]) {
        
        // Get ride of the weired newline chars and whitespace!
        self.currentElementValue = (NSMutableString*)[self.currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.currentElementValue = (NSMutableString*)[self.currentElementValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
        if ([elementName isEqualToString: @"date"]){
            // create NSDate from ex. "Wed, 15 Apr 2015 02:58:51 GMT"
            NSString *withoutDay = [self.currentElementValue substringFromIndex:5];
            NSString *allNum = [Job convertMonthtoNum:withoutDay];
            // now should be format ex. "13 4 2015 19:30:43"
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd MM yyyy HH:mm:ss"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [formatter setTimeZone:gmt];
            [self.iJob setValue:[formatter dateFromString:allNum] forKey:@"datePosted"];
        }
        else if ([elementName isEqualToString: @"url"]) {
            NSScanner *aScanner = [NSScanner scannerWithString:self.currentElementValue];
            NSString *newURL = [[NSString alloc] init];
            [aScanner scanUpToString:@"&qd=" intoString:&newURL];
//            NSLog(@"newURL: %@", newURL);
            [self.iJob setValue:newURL forKey:elementName];
        }
        else
            [self.iJob setValue: self.currentElementValue forKey: elementName];
    }
    
    // Reset the variable.
    self.currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing Indeed finished");
}

- (void) filterJobs:(UserSettings *)userSettings{
    NSMutableArray *userSkills = userSettings.userSkills;
    for (Job *j in self.jobs){
        // Compare skills
        //int count = (int)[userSkills count];
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
            NSMutableArray *jobSnippetWords = (NSMutableArray *)[j.snippet componentsSeparatedByString:@" "];
            for (NSString *word in jobSnippetWords){
                NSString *reformattedWord = [[word lowercaseString] stringByReplacingOccurrencesOfString:@"," withString:@""];
                if ([reformattedWord isEqualToString:userSkill] && !found){
                    j.score += 2;
                    found = true;
                }
            }
        }
        // In the right city?
        if ([userSettings.preferredCity isEqualToString:[[j.city lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""]]){
            j.score += 2;
        }
        // How recent is the listing
        NSTimeInterval relativeTimeSeconds;
        relativeTimeSeconds = [[NSDate date]timeIntervalSinceDate: j.datePosted]; //seconds since job posted
        if (relativeTimeSeconds < 86400){       // Is this posting less than a day old
            j.score += 3;
        }
        else if (relativeTimeSeconds < 604800){ // Is this posting less than a week old
            j.score += 1;
        }
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

@end
