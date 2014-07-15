//
//  LoginViewController.m
//  TemplateApp
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import "LoginViewController.h"
#import "ParseStarterProjectAppDelegate.h"
#import "ParseStarterProject-Swift.h"
#import "SignUpViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual: @"RegisterSegue"]) {
        SignUpViewController* next = ((SignUpViewController*)([segue destinationViewController]));
        [next updateUserFields:self.userTextField.text withPassword:self.passwordTextField.text];
    }
}


- (IBAction)immediateBrowsing:(UIButton *)sender {
    [self performSegueWithIdentifier:@"JumpIn" sender:self];
}

- (IBAction)loginPress {
    //authenticate into user with
    NSString* username = self.userTextField.text;
    NSString* password = self.passwordTextField.text;
    //connect to server + authenticate here (BACKEND)
    [ServerInteractor loginUser:username password:password sender:self];
    if (DEBUG_FLAG) {
        //NSLog(@"Logging in %@", username);
    }
}
- (IBAction)loginWithFacebook:(UIButton *)sender {
    NSLog(@"Logging with FB");
    [ServerInteractor loginWithFacebook:self];
}

- (void) successfulLogin {
    [self performSegueWithIdentifier:@"JumpIn" sender:self];
}
- (void) failedLogin: (NSString*) msg {
    [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:msg delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
}

@end
