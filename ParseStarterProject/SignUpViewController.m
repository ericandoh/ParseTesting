//
//  SignUpViewController.m
//  TemplateApp
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import "ParseStarterProjectAppDelegate.h"
#import "SignUpViewController.h"
#import "FashionStash-Swift.h"

@implementation SignUpViewController

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
    if (_prevPassWord != nil) {
        self.passwordTextField.text =_prevPassWord;
    }
    if (_prevUserName != nil) {
        self.userTextField.text = _prevUserName;
    }
    
    self.userTextField.borderStyle = UITextBorderStyleNone;
    self.userTextField.layer.borderWidth = 1;
    self.userTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.userTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.layer.borderWidth = 1;
    self.passwordTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.emailTextField.borderStyle = UITextBorderStyleNone;
    self.emailTextField.layer.borderWidth = 1;
    self.emailTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.emailTextField.keyboardAppearance = UIKeyboardAppearanceDark;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signUpPressed:(id)sender {
    NSString* username = self.userTextField.text;
    NSString* email = self.emailTextField.text;
    NSString* password = self.passwordTextField.text;
    NSString* firstName = @"";//self.firstNameTextField.text;
    NSString* lastName = @"";//self.lastNameTextField.text;
    //register user with server here (BACKEND)
    [ServerInteractor registerUser:username email:email password:password firstName:firstName lastName:lastName sender:self];
    if (DEBUG_FLAG) {
        NSLog(@"registering user %@", username);
    }
}


- (void) successfulSignUp {
    [self performSegueWithIdentifier:@"JumpIn" sender:self];
}
- (void) failedSignUp: (NSString*) msg {
    [[[UIAlertView alloc] initWithTitle:@"Signup Failed" message:msg delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
}
- (void) updateUserFields:(NSString*)userfield withPassword: (NSString*) password
{
    _prevUserName = userfield;
    _prevPassWord = password;
}
- (IBAction)backPress:(UIButton *)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
