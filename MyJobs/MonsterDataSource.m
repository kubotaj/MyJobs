//
//  MonsterDataSource.m
//  MyJobs
//
//  Created by student on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "MonsterDataSource.h"

@interface MonsterDataSource()

@property (nonatomic) NSString *monsterURLString;
@property (nonatomic) Job *mJob;
@property (nonatomic) NSMutableArray *jobs;
@property (nonatomic) NSString *currentElement;
@property (nonatomic) NSMutableString *currentElementValue;
@property (nonatomic) BOOL *didStartItem;

@end

@implementation MonsterDataSource

-(instancetype) initWithURLString: (NSString *) urlString {
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    
    self.didStartItem = NO;
    // Setup the parser
    self.monsterURLString = urlString;
    NSURL *url = [NSURL URLWithString: self.monsterURLString];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = self;
    // Start parsing
    BOOL success = [parser parse];
    // Verification.
    if (success) {
        NSLog(@"No errors - result count : %i", [self.jobs count]);
    }
    else {
        NSLog(@"Error parsing document!");
    }
    
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Start monster parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parsing error");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"Element[%@]found", elementName);
    
    /* Create a new instance of mJob */
    if ([elementName isEqualToString: @"item"]) {
        self.didStartItem = YES;
        self.mJob = [[Job alloc] init];
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
    if ([elementName isEqualToString: @"channel"]) {
        return;
    }
    
    if ([elementName isEqualToString:@"item"]) {
        // End of one result. Add it to the array.
        if (!self.jobs) {
            self.jobs = [[NSMutableArray alloc] init];
        }
        [self.jobs addObject: self.mJob];
        // release object
        self.mJob = nil;
        self.didStartItem = NO; //comment
    }
    else if (self.didStartItem &&
             ( [elementName isEqualToString: @"title"] ||
             [elementName isEqualToString: @"description"] ||
             [elementName isEqualToString: @"link"] ||
             [elementName isEqualToString: @"pubDate"] )) {
        
        // Get ride of the weired newline chars and whitespace!
        self.currentElementValue = [self.currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.currentElementValue = [self.currentElementValue stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
        
        if ([elementName isEqualToString: @"title"])
            [self.mJob setValue:self.currentElementValue forKey: @"jobtitle"];
        
        if ([elementName isEqualToString: @"description"]) {
            [self.mJob setValue:@"" forKey:@"company"]; //set company to empty string
            
            NSString *descriptionInput = self.currentElementValue; //grab all of description
            NSString *seperatorString = @","; //seperate on the comma
            
            NSScanner *aScanner = [NSScanner scannerWithString:descriptionInput]; //init scanner with whole description
            
            NSString *location = [[NSString alloc] init];
            [aScanner scanUpToString:seperatorString intoString:&location]; //scan until finds a comma, puts everything before it into location
            [self.mJob setValue:location forKey:@"city"]; // set the location string to the city
            [self.mJob setValue:@"" forKey:@"state"]; // set state to empty string
            //NSLog(@"location: %@", location);
            
            NSString *descriptionFinal = [[NSString alloc] init]; // init parsed description

            descriptionFinal = [descriptionInput substringFromIndex:[aScanner scanLocation]+2]; //final description is substring starting at last scan location to end of string
            [self.mJob setValue:descriptionFinal forKey:@"snippet"];
            //NSLog(@"description: %@", descriptionFinal);
            
        }
        
        if ([elementName isEqualToString: @"link"])
            [self.mJob setValue:self.currentElementValue forKey:@"url"];
        
        if ([elementName isEqualToString: @"pubDate"]) {
            [self.mJob setValue:self.currentElementValue forKey:@"formattedRelativeTime"];
            // create NSDate from ex. "Wed, 15 Apr 2015 02:58:51 GMT"
            NSString *withoutDay = [self.currentElementValue substringFromIndex:5];
            NSString *allNum = [Job convertMonthtoNum:withoutDay];
            // now should be format ex. "13 4 2015 19:30:43"
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd MM yyyy HH:mm:ss"];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [formatter setTimeZone:gmt];
            [self.mJob setValue:[formatter dateFromString:allNum] forKey:@"datePosted"];
            NSLog(@"%@", self.mJob.datePosted);
        }
        
        //[self.mJob setValue: self.currentElementValue forKey: elementName];
    }
    
    // Reset the variable.
    self.currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing monster finished");
    
    for (int i = 0; i < [self.jobs count]; i++) {
        //NSLog(@"Job %i job title is %@", i, [self.jobs[i] valueForKey: @"jobtitle"]);
    }
}

- (NSMutableArray *) getAllJobs {
    return self.jobs;
}

- (NSInteger *) getNumberOfJobs {
    return [self.jobs count];
}

- (Job *) jobAtIndex: (NSInteger *) idx {
    if( idx >= [self.jobs count] )
        return nil;
    
    return [self.jobs objectAtIndex: idx];
}

@end
