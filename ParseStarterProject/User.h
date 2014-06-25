//
//  User.h
//  TemplateApp
//
//  Represents a User.
//  If I use Parse, this will be not used (use Parse's API for User instead - PFUser)
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

//stupid comment
//stupid comment 2

@property (nonatomic, strong) NSString* name;
@property (nonatomic) int userID;

@end
