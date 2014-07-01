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
        NSLog("Made new post")
        newPost.myObj.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!)->Void in
            if (succeeded && !error) {
                NSLog("Succeeded, now pushing other notif objects");
                var notifObj = PFObject(className:"Notification");
                //type of notification - in this case, a Image Post (how many #likes i've gotten)
                notifObj["type"] = "ImagePost";
                notifObj["ImagePost"] = newPost.myObj;
                
                ServerInteractor.processNotification(PFUser.currentUser(), targetObject: notifObj);
                //ServerInteractor.saveNotification(PFUser.currentUser(), targetObject: notifObj)
            }
            else {
                NSLog("Soem error of some sort")
            }
        });
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
        query.whereKey("author", equalTo: PFUser.currentUser().username);
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
    class func processNotification(targetUser: PFUser, targetObject: PFObject)->Array<AnyObject?>? {
        targetObject.ACL.setReadAccess(true, forUser: targetUser)
        targetObject.ACL.setWriteAccess(true, forUser: targetUser)
        
        targetObject["sender"] = PFUser.currentUser();  //this is necessary for friends!
        targetObject["recipient"] = targetUser;
        targetObject["viewed"] = false;
        
        targetObject.saveInBackground();
        
        return nil; //useless statement to suppress useless stupid xcode thing
    }
    /*class func saveNotification(targetUser: PFUser, targetObject: PFObject)->Array<PFObject?>? {
        
        //targetObject.ACL.setPublicReadAccess(true);
        //targetObject.ACL.setPublicWriteAccess(true);
        
        targetObject.ACL.setReadAccess(true, forUser: targetUser)
        targetObject.ACL.setWriteAccess(true, forUser: targetUser)
        
        targetUser.addObject(targetObject, forKey: "notifs");
        var notifArray = targetUser["notifs"] as Array<PFObject>
        
        NSLog("Notif size: \(notifArray.count)")
        
        if (notifArray.count > 20) {
            
            //find oldest item and delete it
            var oldestDate: NSDate = notifArray[0].updatedAt;
            var oldestItem: PFObject = notifArray[0];
            var oldestIndex: Int = 0;
            
            var listItem: PFObject;
            //had enumeration error: check this
            for index: Int in 0..notifArray.count {
                listItem = notifArray[index]
                if (listItem.updatedAt != nil && listItem.updatedAt.compare(oldestDate) == NSComparisonResult.OrderedAscending) {
                    //this is the oldest
                    oldestItem = listItem;
                    oldestDate = listItem.updatedAt;
                    oldestIndex = index;
                }
            }
            oldestItem.deleteInBackground();
            notifArray.removeAtIndex(oldestIndex);
            targetUser["notifs"] = notifArray;
        }
        targetUser.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError!)-> Void in
            if (!error) {
                //NSLog("Saved user successfully")
            }
            else {
                NSLog("Soemthing is very very wrong")
            }
            });
        return nil
    }*/
    
    class func getNotifications(controller: NotifViewController) {
        //var returnList = Array<InAppNotification?>(count: NOTIF_COUNT, repeatedValue: nil);
        //var returnList = Array<InAppNotification?>();
        var query = PFQuery(className:"Notification")
        query.whereKey("recipient", equalTo: PFUser.currentUser());
        //query.limit = loadCount;
        //query.skip = skip * loadCount;
        //want most recent first
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: AnyObject[]!, error: NSError!) -> Void in
            if !error {
                // The find succeeded.
                // Do something with the found objects
                var object: PFObject;
                for index:Int in 0..objects.count {
                    object = objects![index] as PFObject;
                    if (index < NOTIF_COUNT) {
                        NSLog("Fetching notification \(index)");
                        //returnList[index] = InAppNotification(dataObject: object);
                        if(index >= controller.notifList.count) {
                            controller.notifList.append(InAppNotification(dataObject: object));
                        }
                        else {
                            controller.notifList[index] = InAppNotification(dataObject: object, message: controller.notifList[index]!.messageString);
                        }
                        controller.notifList[index]!.assignMessage(controller);
                    }
                    else {
                        if (object["viewed"]) {
                            object.deleteInBackground();
                            continue;
                        }
                    }
                    object["viewed"] = true;
                    object.saveInBackground();
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        
        
        
        
        
        
        /*
        var returnList = Array<InAppNotification?>()
        var currentNotifs: Array<PFObject>;
        if ( PFUser.currentUser()["notifs"] != nil) {
            currentNotifs = PFUser.currentUser()["notifs"] as Array<PFObject>;
        }
        else {
            currentNotifs = Array<PFObject>();
            PFUser.currentUser().addObjectsFromArray(currentNotifs, forKey: "notifs");
            PFUser.currentUser().saveInBackground();    //is this needed?
            //PFUser.currentUser()["notifs"] = currentNotifs;
        }
        //how many post-notifications we need
        NSLog("We have \(currentNotifs.count) notifications")
        for index in 0..(currentNotifs.count) {
            returnList.append(InAppNotification(dataObject: currentNotifs[index]));
        }
        return returnList*/
    }
    //used for default message notifications (i.e. "You have been banned for violating TOS" "Welcome to our app"
    //"Happy April Fool's Day!")
    class func postDefaultNotif(txt: String) {
        //posts a custom notification (like friend invite, etc)
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a default text one
        notifObj["type"] = "PlainText";
        notifObj["message"] = txt
        //notifObj.saveInBackground()
        
        ServerInteractor.processNotification(PFUser.currentUser(), targetObject: notifObj);
        //saveNotification(PFUser.currentUser(), targetObject: notifObj)
    }
    //you have just requested someone as a friend; this sends the friend you are requesting a notification for friendship
    class func postFriendRequest(friendName: String, controller: UIViewController) {
        if (friendName == "") {
            (controller as SettingsViewController).notifyFailure("Please fill in a name");
            return;
        }
        
        //first, query + find the user
        var query: PFQuery = PFUser.query();
        query.whereKey("username", equalTo: friendName)
        query.findObjectsInBackgroundWithBlock({ (objects: AnyObject[]!, error: NSError!) -> Void in
                if (objects.count > 0) {
                    //i want to request myself as a friend to my friend
                    var notifObj = PFObject(className:"Notification");
                    notifObj["type"] = "FriendRequest";
                    //notifObj.saveInBackground();
                    
                    var friend = objects[0] as PFUser;
                    ServerInteractor.processNotification(friend, targetObject: notifObj);
                    //ServerInteractor.saveNotification(friend, targetObject: notifObj)
                    
                }
                else {
                    //controller.makeNotificationThatFriendYouWantedDoesntExistAndThatYouAreVeryLonely
                    (controller as SettingsViewController).notifyFailure(error.userInfo["error"] as String);
                }
            });
    }
    //you have just accepted your friend's invite; your friend now gets informed that you are now his friend <3
    //note: the func return type is to suppress some stupid thing that happens when u have objc stuff in your swift header
    class func postFriendAccept(friend: PFUser)->Array<AnyObject?>? {
        //first, query + find the user
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = "FriendAccept";
        //notifObj.saveInBackground();
        
        processNotification(friend, targetObject: notifObj);
        //saveNotification(friend, targetObject: notifObj)
        
        /*var notifArray = friend["notifs"] as Array<PFObject>
        notifArray.insert(notifObj, atIndex: 0)
        if (notifArray.count > 20) {
            notifArray.removeLast()
        }
        friend.saveInBackground()*/
        
        return nil;
    }
}
