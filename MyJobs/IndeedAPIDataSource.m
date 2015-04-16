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
@property (nonatomic) IndeedJob *iJob;
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
    NSLog(@"Start parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parsing error");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    NSLog(@"Element[%@]found", elementName);
    
    /* Create a new instance of iJob */
    if ([elementName isEqualToString: @"result"]) {
        self.iJob = [[IndeedJob alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"String[%@]found", string);
    
    if (!self.currentElementValue) {
        self.currentElementValue = [[NSMutableString alloc] initWithString: string];
    }
    else {
        [self.currentElementValue appendString: string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    NSLog(@"Element[%@]finished", elementName);
    
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
             [elementName isEqualToString: @"formattedRelativeTime"]) {
        [self.iJob setValue: self.currentElementValue forKey: elementName];
        
        // Get ride of the wired newline chars and whitespace!
        // There should be a beter way than this!
        if ([elementName isEqualToString: @"jobtitle"]) {
            self.iJob.jobtitle = [self.iJob.jobtitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.jobtitle = [self.iJob.jobtitle stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([elementName isEqualToString: @"company"]) {
            self.iJob.company = [self.iJob.company stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.company = [self.iJob.company stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([elementName isEqualToString: @"city"]) {
            self.iJob.city = [self.iJob.city stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.city = [self.iJob.city stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([elementName isEqualToString: @"state"]) {
            self.iJob.state = [self.iJob.state stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.state = [self.iJob.state stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([elementName isEqualToString: @"snippet"]) {
            self.iJob.snippet = [self.iJob.snippet stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.snippet = [self.iJob.snippet stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([elementName isEqualToString: @"url"]) {
            self.iJob.url = [self.iJob.url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.url = [self.iJob.url stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        }
        else {
            self.iJob.formattedRelativeTime = [self.iJob.formattedRelativeTime stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.iJob.formattedRelativeTime = [self.iJob.formattedRelativeTime stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        }
    }
    
    // Reset the variable.
    self.currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing finished");

    NSLog(@"jobs count is %d", self.jobs.count);
    for (int i = 0; i < [self.jobs count]; i++) {
        NSLog(@"Job %i job title is %@", i, [self.jobs[i] valueForKey: @"jobtitle"]);
    }
}

- (NSMutableArray *) getAllJobs {
    return self.jobs;
}

- (NSInteger *) getNumberOfJobs {
    return [self.jobs count];
}

- (IndeedJob *) jobAtIndex: (NSInteger *) idx {
    if( idx >= [self.jobs count] )
        return nil;
    
    return [self.jobs objectAtIndex: idx];
}

@end
