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

@end

@implementation MonsterDataSource

-(instancetype) initWithURLString: (NSString *) urlString {
    /* Initializer */
    if( (self = [super init]) == nil )
        return nil;
    
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
    }
    else if ([elementName isEqualToString: @"title"] ||
             [elementName isEqualToString: @"description"] ||
             [elementName isEqualToString: @"link"] ||
             [elementName isEqualToString: @"pubDate"]) {
        
        // Get ride of the weired newline chars and whitespace!
        self.currentElementValue = [self.currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.currentElementValue = [self.currentElementValue stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
        
        if ([elementName isEqualToString: @"title"])
            [self.mJob setValue:self.currentElementValue forKey: @"jobtitle"];
        
        if ([elementName isEqualToString: @"description"]) {
//            NSLog(@"DESCRIP");
//            NSString *state = [self.currentElementValue substringWithRange:NSMakeRange(0, 1)]; //get the state
//            [self.mJob setValue:state forKey:@"state"]; //add state to job
//            NSLog(@"STATE: ", state);
//            self.currentElementValue = [self.currentElementValue substringFromIndex:3]; //remove state from description
//            NSArray *components = [self.currentElementValue componentsSeparatedByString:@", "]; //parse based on ', '
//            NSString *city = [components objectAtIndex:0]; // string before the first ', '
//            [self.mJob setValue:city forKey:@"city"];
//            NSRange range = [self.currentElementValue rangeOfString:@", "]; //find index of first ', '
//            self.currentElementValue = [self.currentElementValue substringFromIndex:range.location]; // remove everything after the first ', '
            [self.mJob setValue:self.currentElementValue forKey:@"snippet"];
        }
        
        if ([elementName isEqualToString: @"link"])
            [self.mJob setValue:self.currentElementValue forKey:@"url"];
        
        if ([elementName isEqualToString: @"pubDate"]) {
            
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
