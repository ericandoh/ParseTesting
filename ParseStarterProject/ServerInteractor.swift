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

@objc class ServerInteractor: NSObject {
    class func someTypeMethod() {
        
    }
    //---------------User Login/Signup/Interaction Methods---------------------------------
    class func registerUser(username: String, email: String, password: String, sender: NSObject)->Bool {
        var user: PFUser = PFUser();
        user.username = username;
        user.password = password;
        user.email = email;
        
        user.signUpInBackgroundWithBlock( {(succeeded: Bool, error: NSError!) in
            var signController: SignUpViewController = sender as SignUpViewController;
            if (!error) {
                
                //other notification objects associated (array of other PFObjects which have ref to other datum)
                //use PFRelation here instead (wait how do we do that?)
                var emptyArray = Array<PFObject>();
                user.addObjectsFromArray(emptyArray, forKey: "notifs");
                //user["notifs"] = emptyArray;
                
                //user.relationForKey("notifs")
                
                
                //success!
                //sign in user
                //send some sort of notif to bump screen?
                ServerInteractor.postDefaultNotif("Welcome to InsertAppName! Thank you for signing up for our app!");
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
    //use this to check whether to go to signup/login screen or directly to home
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
    //use this to handle disabling/enabling of signoff button
    class func isAnonLogged()->Bool {
        return PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser());
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
    //------------------Image Post related methods---------------------------------------
    class func uploadImage(image: UIImage) {
        var newPost = ImagePostStructure(image: image);
        newPost.save();
        
        //add notification here WORKNEED
        
        //upload - relational data is saved as well
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a Image Post (how many #likes i've gotten)
        notifObj["type"] = "ImagePost";
        notifObj["ImagePost"] = newPost.myObj;
        notifObj.saveInBackground()
        
        
        var notifArray = PFUser.currentUser()["notifs"] as Array<PFObject>
        notifArray.insert(notifObj, atIndex: 0)
        if (notifArray.count > 20) {
            notifArray.removeLast()
        }
        PFUser.currentUser().saveInBackground()
    }
    //return ImagePostStructure(image, likes)
    //counter = how many pages I've seen (used for pagination)
    //this method DOES fetch the images along with the data
    class func getPost(skip: Int)->Array<ImagePostStructure?> {
        //download - relational data is NOT fetched!
        var returnList = Array<ImagePostStructure?>(count: POST_LOAD_COUNT, repeatedValue: nil);
        //query
        var query = PFQuery(className:"ImagePost")
        query.skip = skip * POST_LOAD_COUNT;
        query.limit = POST_LOAD_COUNT;
        query.orderByDescending("likes");
        //query addAscending/DescendingOrder for extra ordering:
        query.findObjectsInBackgroundWithBlock {
            (objects: AnyObject[]!, error: NSError!) -> Void in
            if !error {
                // The find succeeded.
                // Do something with the found objects
                for (index, object:PFObject!) in enumerate(objects!) {
                    returnList[index] = ImagePostStructure(inputObj: object, shouldLoadImage: true);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        return returnList;
    }
    class func getMySubmissions(skip: Int)->Array<ImagePostStructure?> {
        return getMySubmissions(skip, loadCount: MYPOST_LOAD_COUNT);
    }
    //returns a list of my submissions (once again restricted by POST_LOAD_COUNT
    //does NOT autoload the image with the file
    //return reference to PFFile as well - use to load files later on
    class func getMySubmissions(skip: Int, loadCount: Int)->Array<ImagePostStructure?>  {
        var returnList = Array<ImagePostStructure?>(count: POST_LOAD_COUNT, repeatedValue: nil);
        
        var query = PFQuery(className:"ImagePost")
        query.whereKey("author", equalTo: PFUser.currentUser());
        query.limit = loadCount;
        query.skip = skip * loadCount;
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: AnyObject[]!, error: NSError!) -> Void in
            if !error {
                // The find succeeded.
                // Do something with the found objects
                for (index, object:PFObject!) in enumerate(objects!) {
                    returnList[index] = ImagePostStructure(inputObj: object, shouldLoadImage: false);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        
        return returnList;
    }
    //------------------Notification related methods---------------------------------------
    class func getNotifications()->Array<InAppNotification?> {
        //var returnList = Array<InAppNotification?>(count: NOTIF_COUNT, repeatedValue: nil)
        NSLog("Lets investigate this one")
        var returnList = Array<InAppNotification?>()
        var currentNotifs: Array<PFObject>;
        if ( PFUser.currentUser()["notifs"] != nil) {
            NSLog("Retrieving notif category for this user")
            currentNotifs = PFUser.currentUser()["notifs"] as Array<PFObject>;
        }
        else {
            NSLog("No notif category???")
            currentNotifs = Array<PFObject>();
            PFUser.currentUser().setValue(currentNotifs, forKey: "notifs")
            //PFUser.currentUser()["notifs"] = currentNotifs;
        }
        NSLog("Fetched \(currentNotifs.count)")
        //how many post-notifications we need
        for index in 0..(currentNotifs.count) {
            returnList.append(InAppNotification(dataObject: currentNotifs[index]));
        }
        return returnList
    }
    //used for default message notifications (i.e. "You have been banned for violating TOS" "Welcome to our app"
    //"Happy April Fool's Day!")
    class func postDefaultNotif(txt: String) {
        //posts a custom notification (like friend invite, etc)
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a default text one
        notifObj["type"] = "PlainText";
        notifObj["message"] = txt
        notifObj.saveInBackground()
        
        var notifArray = PFUser.currentUser()["notifs"] as Array<PFObject>
        //notifArray.insert(notifObj, atIndex: 0)
        PFUser.currentUser().addObject(notifObj, forKey: "notifs");
        //this worked: PFUser.currentUser().addObjectsFromArray(notifArray, forKey: "notifs");
        //^^ what the **** is going on
        
        if (notifArray.count > 20) {
            notifArray.removeLast()
        }
        PFUser.currentUser().saveInBackground()
    }
    //you have just requested someone as a friend; this sends the friend you are requesting a notification for friendship
    class func postFriendRequest(friendName: String, controller: UIViewController) {
        //first, query + find the user
        var query: PFQuery = PFUser.query();
        query.whereKey("username", equalTo: friendName)
        query.findObjectsInBackgroundWithBlock({ (objects: AnyObject[]!, error: NSError!) -> Void in
                if (objects.count > 0) {
                    //i want to request myself as a friend to my friend
                    var notifObj = PFObject(className:"Notification");
                    notifObj["type"] = "FriendRequest";
                    notifObj["friend"] = PFUser.currentUser();
                    notifObj.saveInBackground();
                    
                    var friend = objects[0] as PFUser;
                    
                    var notifArray = friend["notifs"] as Array<PFObject>
                    notifArray.insert(notifObj, atIndex: 0)
                    if (notifArray.count > 20) {
                        notifArray.removeLast()
                    }
                    friend.saveInBackground()
                    
                } else {
                    //controller.makeNotificationThatFriendYouWantedDoesntExistAndThatYouAreVeryLonely
                }
            });
    }
    //you have just accepted your friend's invite; your friend now gets informed that you are now his friend <3
    //note: the func return type is to suppress some stupid thing that happens when u have objc stuff in your swift header
    class func postFriendAccept(friend: PFUser)->Array<AnyObject?>? {
        //first, query + find the user
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = "FriendAccept";
        notifObj["friend"] = PFUser.currentUser();
        notifObj.saveInBackground();
        
        var notifArray = friend["notifs"] as Array<PFObject>
        notifArray.insert(notifObj, atIndex: 0)
        if (notifArray.count > 20) {
            notifArray.removeLast()
        }
        friend.saveInBackground()
        
        return nil;
    }
}
