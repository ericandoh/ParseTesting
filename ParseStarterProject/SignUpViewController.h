//
//  SignUpViewController.h
//  TemplateApp
//
//  View controller for signup page
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;


@property NSString* prevUserName;
@property NSString* prevPassWord;

- (IBAction)signUpPressed:(id)sender;
- (IBAction)textFieldReturn:(UITextField *)sender;


- (void) successfulSignUp;
- (void) failedSignUp: (NSString*) msg;
- (void) updateUserFields:(NSString*)userfield withPassword: (NSString*) password;

@end
