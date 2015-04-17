//
//  CareerBuilderAPIDataSource.m
//  MyJobs
//
//  Created by student on 4/17/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "CareerBuilderAPIDataSource.h"

@interface CareerBuilderAPIDataSource()

@property (nonatomic) NSString *cbURLString;
@property (nonatomic) Job *cbJob;
@property (nonatomic) NSMutableArray *jobs;
@property (nonatomic) NSString *currentElement;
@property (nonatomic) NSMutableString *currentElementValue;

@end

@implementation CareerBuilderAPIDataSource

-(instancetype) initWithURLString: (NSString *) urlString {
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    
    // Setup the parser
    self.cbURLString = urlString;
    NSURL *url = [NSURL URLWithString: self.cbURLString];
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
        self.cbJob = [[Job alloc] init];
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
        [self.jobs addObject: self.cbJob];
        // release object
        self.cbJob = nil;
    }
    else if ([elementName isEqualToString: @"ONetFriendlyTitle"] ||
             [elementName isEqualToString: @"Company"] ||
             [elementName isEqualToString: @"City"] ||
             [elementName isEqualToString: @"State"] ||
             [elementName isEqualToString: @"DescriptionTeaser"] ||
             [elementName isEqualToString: @"JobDetailsURL"] ||
             [elementName isEqualToString: @"PostedTime"]) {
        
        // Get ride of the weired newline chars and whitespace!
        self.currentElementValue = [self.currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.currentElementValue = [self.currentElementValue stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
        
        if ([elementName isEqualToString: @"ONetFriendlyTitle"])
            [self.cbJob setValue: self.currentElementValue forKey: @"jobtitle"];
        if ([elementName isEqualToString: @"Company"])
            [self.cbJob setValue: self.currentElementValue forKey: @"company"];
        if ([elementName isEqualToString: @"City"])
            [self.cbJob setValue: self.currentElementValue forKey: @"city"];
        if ([elementName isEqualToString: @"State"])
            [self.cbJob setValue: self.currentElementValue forKey: @"state"];
        if ([elementName isEqualToString: @"DescriptionTeaser"])
            [self.cbJob setValue: self.currentElementValue forKey: @"snippet"];
        if ([elementName isEqualToString: @"JobDetailsURL"])
            [self.cbJob setValue: self.currentElementValue forKey: @"url"];
        if ([elementName isEqualToString: @"PostedTime"])
            [self.cbJob setValue: self.currentElementValue forKey: @"formattedRelativeTime"];
    }
    
    // Reset the variable.
    self.currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing finished");
    
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

- (Job *) jobAtIndex: (NSInteger *) idx {
    if( idx >= [self.jobs count] )
        return nil;
    
    return [self.jobs objectAtIndex: idx];
}

@end