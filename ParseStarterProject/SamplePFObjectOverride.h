//
//  SamplePFObjectOverride.h
//  TemplateApp
//
//  Sample subclass of PFObject
//  Don't forget to register this in my AppDelegate file!
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import <Parse/Parse.h>

// <PFSubclassing>

@interface SamplePFObjectOverride : PFObject

+(NSString*)parseClassName;

-(void) exampleMethod;

-(id)initFromDictionary:(NSDictionary*) dictionary;
-(NSDictionary*) dictionary;

@end
