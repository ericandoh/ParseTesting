//
//  StoreableNSObject.m
//  TemplateApp
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import "SamplePFObjectOverride.h"

@implementation SamplePFObjectOverride: PFObject

+(NSString*)parseClassName
{
    return @"StoreableNSObject";
}

-(void) exampleMethod
{
    //set a variable
    self[@"varName"] = @1337;
    
    //modify a variable
    [self incrementKey:@"score"];
    [self incrementKey:@"score" byAmount:@1337];
    
    
    //add to list
    //also have addObject:forKey, addObjectsFromArray:forKey, removeObject:forKey and removeObjectsInArray:forKey
    [self addUniqueObjectsFromArray:@[@"flying", @"kungfu"] forKey:@"skills"];
    [self saveInBackground];
    
    //you can even store other PFObjects!
    self[@"parent"] = [PFObject objectWithClassName:@"Post"];
    
    
    //save myself
    [self saveInBackground];
    //or if i don't need to be notified when it saves (probably use this one)
    [self saveEventually];
    
    //retrieve objects
    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
    
    [query getObjectInBackgroundWithId:@"xWMyZ4YEGZ" block:^(PFObject *gameScore, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", gameScore);
    }];
    
    //or if i need to refresh this data object:
    [self refresh];
    
    //delete myself from cloud
    [self deleteInBackground];
    
    //remove single field?
    [self removeObjectForKey:@"playername"];
    [self saveInBackground];
    
}

-(id)initFromDictionary:(NSDictionary*) dictionary
{
    //do nothing
    return self;
}
-(NSDictionary*) dictionary
{
    //do nothing
    return nil;
}

@end
