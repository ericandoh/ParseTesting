//
//  ServerInteractor.swift
//  ParseStarterProject
//
//  Code to handle all the server-interactions with this app (keeping it in one place for easy portability)
//
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

//use PFUser.currentUser
//var currentUser: PFUser? = nil;

class ServerInteractor: NSObject {
    class func someTypeMethod() {
        
    }
    class func registerUser(username: String, email: String, password: String, sender: NSObject)->Bool {
        
        /*if (currentUser) {
            //already logged in
            
            //either sign off current user + make new, or cancel
            return false;
        }*/
        
        var user: PFUser = PFUser();
        user.username = username;
        user.password = password;
        user.email = email;
        
        user.signUpInBackgroundWithBlock( {(succeeded: Bool, error: NSError!) in
            var signController: SignUpViewController = sender as SignUpViewController;
            if (!error) {
                //success!
                
                //sign in user
                //currentUser = user;
                
                //send some sort of notif to bump screen?
                signController.successfulSignUp();
                
            } else {
                var errorString: String = error.userInfo["error"] as String;
                //display this error string to user
                
                //send some sort of notif to refresh screen?
                signController.failedSignUp(errorString);
            }
        });
        return true;
    }
    class func loginUser(username: String, password: String, sender: NSObject)->Bool {
        /*if (currentUser) {
            //already logged in
            //either sign off current user + login new, or cancel
            return false;
        }*/
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser!, error: NSError!) in
            var logController: LoginViewController = sender as LoginViewController;
            if (user) {
                //successful log in
                logController.successfulLogin();
            }
            else {
                //login failed
                var errorString: String = error.userInfo["error"] as String;
                logController.failedLogin(errorString);
            }
        });
        return true;
    }
    //logged in as anonymous user does NOT count
    class func isUserLogged()->Bool {
        if (PFUser.currentUser != nil) {
            if (PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())) {
                //anonymous user
                return false;
            }
            return true;
        }
        return false;
    }
    class func logOutUser() {
        PFUser.logOut();
    }
    class func logInAnon() {
        PFAnonymousUtils.logInWithBlock {
            (user: PFUser!, error: NSError!) -> Void in
            if error {
                NSLog("Anonymous login failed.")
            } else {
                NSLog("Anonymous user logged in.")
            }
        }
    }
    class func resetPassword(email: String) {
        PFUser.requestPasswordResetForEmailInBackground(email)
    }
    
    /*
    PFQuery *query = [PFUser query];
    [query whereKey:@"gender" equalTo:@"female"]; // find all the women
    NSArray *girls = [query findObjects];
    
    
    */
}
