//
//  ServerInteractor.swift
//  ParseStarterProject
//
//  Code to handle all the server-interactions with this app (keeping it in one place for easy portability)
//  Mostly communications with Parse and PFObjects
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
        
        user["friends"] = NSArray();
        
        user.signUpInBackgroundWithBlock( {(succeeded: Bool, error: NSError!) in
            var signController: SignUpViewController = sender as SignUpViewController;
            if (!error) {
                //success!
                //sees if user has pending items to process
                ServerInteractor.initialUserChecks();
                //user's first notification
                ServerInteractor.postDefaultNotif("Welcome to InsertAppName! Thank you for signing up for our app!");
                signController.successfulSignUp();
                
            } else {
                var errorString: String = error.userInfo["error"] as String;
                //display this error string to user
                //send some sort of notif to refresh screen
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
                ServerInteractor.initialUserChecks();
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
    
    //loggin in with facebook
    class func loginWithFacebook(sender: NSObject) {
        //whats permissions
        //permissions at https://developers.facebook.com/docs/facebook-login/permissions/v2.0
        //sample permissions: ["user_about_me", "user_relationships", "user_birthday", "user_location"]
        let permissions: AnyObject[]? = ["user_about_me", "user_relationships"];
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            var logController: LoginViewController = sender as LoginViewController;
            if (error) {
                NSLog("Error message: \(error!.description)");
            } else if !user {
                logController.failedLogin("Uh oh. The user cancelled the Facebook login.");
            } else if user.isNew {
                logController.failedLogin("User signed up and logged in through Facebook!")
            } else {
                logController.failedLogin("User logged in through Facebook!")
            }
        });
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
    class func uploadImage(image: UIImage, exclusivity: PostExclusivity) {
        if (isAnonLogged()) {
            return;
        } else {
        var newPost = ImagePostStructure(image: image, exclusivity: exclusivity);
        var sender = PFUser.currentUser().username;     //in case user logs out while object is still saving
        newPost.myObj.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!)->Void in
            if (succeeded && !error) {
                if (PFUser.currentUser()["userIcon"] == nil) {
                    //above may set to last submitted picture...? sometimes??
                    //might consider just resizing image to a smaller icon value and saving it again
                    PFUser.currentUser()["userIcon"] = newPost.myObj["imageFile"];
                    PFUser.currentUser().saveEventually();
                }
                var notifObj = PFObject(className:"Notification");
                //type of notification - in this case, a Image Post (how many #likes i've gotten)
                notifObj["type"] = NotificationType.IMAGE_POST.toRaw();
                notifObj["ImagePost"] = newPost.myObj;
                
                ServerInteractor.processNotification(sender, targetObject: notifObj);
                //ServerInteractor.saveNotification(PFUser.currentUser(), targetObject: notifObj)
            }
            else {
                NSLog("Soem error of some sort")
            }
        });
    }
    }
    
    class func getPost(finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, sender: HomeFeedController) {
        return getPost(true, finishFunction: finishFunction, sender:sender);
    }
    class func removePost(post: ImagePostStructure) {
        post.myObj.deleteInBackground();
    }
    //return ImagePostStructure(image, likes)
    //counter = how many pages I've seen (used for pagination)
    //this method DOES fetch the images along with the data
    class func getPost(friendsOnly: Bool, finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, sender: HomeFeedController) {
        //download - relational data is NOT fetched!
        var returnList = Array<ImagePostStructure?>();
        //query
        var query = PFQuery(className:"ImagePost")
        //query.skip = skip * POST_LOAD_COUNT;
        query.limit = POST_LOAD_COUNT;
        query.orderByDescending("likes");
 
        if (friendsOnly & !isAnonLogged()) {
            query.whereKey("author", containedIn: (PFUser.currentUser()["friends"] as NSArray));
        }
        //query addAscending/DescendingOrder for extra ordering:
        query.findObjectsInBackgroundWithBlock {
            (objects: AnyObject[]!, error: NSError!) -> Void in
            if !error {
                // The find succeeded.
                // Do something with the found objects
                sender.setPostArraySize(objects.count);
                for (index, object:PFObject!) in enumerate(objects!) {
                    var post = ImagePostStructure(inputObj: object);
                    post.loadImage(finishFunction, index: index);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        //return returnList;
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
                    returnList[index] = ImagePostStructure(inputObj: object);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        
        return returnList;
    }
    //------------------Notification related methods---------------------------------------
    class func processNotification(targetUserName: String, targetObject: PFObject)->Array<AnyObject?>? {
        return processNotification(targetUserName, targetObject: targetObject, controller: nil);
    }
    class func processNotification(targetUserName: String, targetObject: PFObject, controller: UIViewController?)->Array<AnyObject?>? {
        
        var query: PFQuery = PFUser.query();
        query.whereKey("username", equalTo: targetUserName)
        var currentUserName = PFUser.currentUser().username;
        query.findObjectsInBackgroundWithBlock({ (objects: AnyObject[]!, error: NSError!) -> Void in
            if (objects.count > 0) {
                //i want to request myself as a friend to my friend
                var targetUser = objects[0] as PFUser;
                targetObject.ACL.setReadAccess(true, forUser: targetUser)
                targetObject.ACL.setWriteAccess(true, forUser: targetUser)
                
                targetObject["sender"] = currentUserName;  //this is necessary for friends!
                targetObject["recipient"] = targetUserName;
                targetObject["viewed"] = false;
                
                targetObject.saveInBackground();
                
            }
            else if (controller) {
                if(objects.count == 0) {
                    (controller! as FriendTableViewController).notifyFailure("No such user exists!");
                }
                else if (error) {
                    //controller.makeNotificationThatFriendYouWantedDoesntExistAndThatYouAreVeryLonely
                    (controller! as FriendTableViewController).notifyFailure(error.userInfo["error"] as String);
                }
            }
        });
        return nil; //useless statement to suppress useless stupid xcode thing
    }
    //deprecated method - ignore
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
        var query = PFQuery(className:"Notification")
        query.whereKey("recipient", equalTo: PFUser.currentUser().username);
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
                    if (index >= NOTIF_COUNT) {
                        if(object["viewed"]) {
                            object.deleteInBackground();
                            continue;
                        }
                    }
                    
                    if(!(object["viewed"] as Bool)) {
                        if (object["type"] != nil) {
                            if ((object["type"] as String) == NotificationType.FRIEND_ACCEPT.toRaw()) {
                                //accept the friend!
                                ServerInteractor.addAsFriend(object["sender"] as String);
                            }
                        }
                        object["viewed"] = true;
                        object.saveInBackground()
                    }
                    if(index >= controller.notifList.count) {
                        var item = InAppNotification(dataObject: object);
                        //weird issue #7 error happening here, notifList is NOT dealloc'd (exists) WORK
                        controller.notifList.append(item);
                    }
                    else {
                        controller.notifList[index] = InAppNotification(dataObject: object, message: controller.notifList[index]!.messageString);
                    }
                    controller.notifList[index]!.assignMessage(controller);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
    }
    //used for default message notifications (i.e. "You have been banned for violating TOS" "Welcome to our app"
    //"Happy April Fool's Day!")
    class func postDefaultNotif(txt: String) {
        //posts a custom notification (like friend invite, etc)
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a default text one
        notifObj["type"] = NotificationType.PLAIN_TEXT.toRaw();
        notifObj["message"] = txt
        //notifObj.saveInBackground()
        
        ServerInteractor.processNotification(PFUser.currentUser().username, targetObject: notifObj);
    }
    //you have just requested someone as a friend; this sends the friend you are requesting a notification for friendship
    class func postFriendRequest(friendName: String, controller: UIViewController) {
        if (friendName == "") {
            (controller as SettingsViewController).notifyFailure("Please fill in a name");
            return;
        }
        
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FRIEND_REQUEST.toRaw();
        ServerInteractor.processNotification(friendName, targetObject: notifObj, controller: controller);
    }
    //you have just accepted your friend's invite; your friend now gets informed that you are now his friend <3
    //note: the func return type is to suppress some stupid thing that happens when u have objc stuff in your swift header
    class func postFriendAccept(friendName: String)->Array<AnyObject?>? {
        //first, query + find the user
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FRIEND_ACCEPT.toRaw();
        //notifObj.saveInBackground();
        
        ServerInteractor.processNotification(friendName, targetObject: notifObj);
        return nil;
    }
    //call this method when either accepting a friend inv or receiving a confirmation notification
    class func addAsFriend(friendName: String)->Array<NSObject?>? {
        PFUser.currentUser().addUniqueObject(friendName, forKey: "friends");
        PFUser.currentUser().saveEventually();
        return nil;
    }
    //call this method when either removing a friend inv directly or when u receive 
    //a (hidden) removefriend notif
    //isHeartBroken: if false, must send (hidden) notif obj to user I am unfriending
    //isHeartBroken: if true, is the user who has just been broken up with. no need to notify friend
    //reason this is NOT a Notification PFObject: I should NOT notify the friend that I broke up with them
    //  (stealthy friend removal) => i.e. if I want to remove a creeper I got deceived into friending
    //RECEIVING END HAS BEEN IMPLEMENTED
    class func removeFriend(friendName: String, isHeartBroken: Bool)->Array<NSObject?>? {
        PFUser.currentUser().removeObject(friendName, forKey: "friends");
        PFUser.currentUser().saveInBackground();
        if (!isHeartBroken) {
            //do NOT use processNotification - we don't want to post a notification
            var breakupObj = PFObject(className:"BreakupNotice")
            breakupObj["sender"] = PFUser.currentUser().username;
            breakupObj["recipient"] = friendName;
            breakupObj.saveInBackground();
            //send notification object
        }
        return nil;
    }
    
    //gets me a list of my friends!
    class func getFriends()->Array<FriendEncapsulator?> {
        var returnList: Array<FriendEncapsulator?> = [];
        var friendz: NSArray;
        if (PFUser.currentUser().allKeys().bridgeToObjectiveC().containsObject("friends")) {
            //if this runs, the code will break catastrophically, just initialize "friends" with registration
            friendz = PFUser.currentUser()["friends"] as NSArray;
        }
        else {
            friendz = Array<PFUser?>();
            PFUser.currentUser()["friends"] = NSArray()
            PFUser.currentUser().saveInBackground();
        }
        var friend: String;
        for index in 0..friendz.count {
            friend = friendz[index] as String;
            returnList.append(FriendEncapsulator(friendName: friend));
        }
        return returnList;
    }
    
    //checks that user should do whenever starting to use app on account
    class func initialUserChecks() {
        //check and see if user has any notice for removal of friends
        var query = PFQuery(className: "BreakupNotice");
        query.whereKey("recipient", equalTo: PFUser.currentUser().username);
        query.findObjectsInBackgroundWithBlock({ (objects: AnyObject[]!, error: NSError!) -> Void in
            var object: PFObject;
            for index: Int in 0..objects.count {
                object = objects[index] as PFObject;
                ServerInteractor.removeFriend(object["sender"] as String, isHeartBroken: true);
                object.deleteInBackground();
            }
        });
    }
}
