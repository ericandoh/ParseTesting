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
    
    
    //---------------User Login/Signup/Interaction Methods---------------------------------
    
    
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
    
    class func getUserName()->String {
        //need to add check checking if I am anon
        return PFUser.currentUser().username;
    }
    
    /*
    PFQuery *query = [PFUser query];
    [query whereKey:@"gender" equalTo:@"female"]; // find all the women
    NSArray *girls = [query findObjects];
    */
    //------------------Image Post related methods---------------------------------------
    class func uploadImage(image: UIImage) {
        //upload file
        let data = UIImagePNGRepresentation(image);
        let file = PFFile(name:"posted.png",data:data);
        file.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) in
            var imagePost = PFObject(className:"ImagePost");
            imagePost["imageFile"] = file;
            imagePost["author"] = PFUser.currentUser();
            imagePost["likes"] = 0;
            imagePost["passes"] = 0;
            });
        //save rest of post info in a PFObject
    }
    
    //return image, likes
    //counter = how many pages I've seen (used for pagination)
    class func getPost(counter: Int)->Array<ImagePostStructure?> {
        
        var returnList = Array<ImagePostStructure?>(count: POST_LOAD_COUNT, repeatedValue: nil);
        
        var query = PFQuery(className:"ImagePost")
        query.skip = counter;
        query.limit = POST_LOAD_COUNT;
        query.orderByDescending("likes");
        query.findObjectsInBackgroundWithBlock {
            (objects: AnyObject[]!, error: NSError!) -> Void in
            if !error {
                // The find succeeded.
                // NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                var imgFile: PFFile;
                for (index, object:PFObject!) in enumerate(objects!) {
                    //NSLog("%@", object.objectId)
                    imgFile = object["imageFile"] as PFFile;
                    imgFile.getDataInBackgroundWithBlock({ (result: NSData!, error: NSError!) in
                        returnList[index] = ImagePostStructure(image: UIImage(data:imgFile.getData()));
                    });
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        
        //query addAscending/DescendingOrder:
        
        
        //return (nil, 0);
        return returnList;
    }
    //return PFFile of image, likes (then pull in PFFile only if needed!)
    class func getMySubmissions()->(PFFile?, Int) {
        return (nil, 0);
    }
}
