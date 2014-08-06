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
    //---------------User Login/Signup/Interaction Methods---------------------------------
    class func registerUser(username: String, email: String, password: String, firstName: String, lastName: String, sender: NSObject)->Bool {
        var signController: SignUpViewController = sender as SignUpViewController;
        if (username.hasPrefix("_")) {
            signController.failedSignUp("Usernames cannot begin with _");
            return false;
        }
        
        var userNameLabel: UILabel
        //var friendObj: PFObject = PFObject(className: "Friendship")
        var user: PFUser = PFUser();
        //friendObj.ACL.setPublicReadAccess(true)
        //friendObj.ACL.setPublicWriteAccess(true)
        user.username = username;
        user.password = password;
        user.email = email;
        
        user["personFirstName"] = firstName;
        user["personLastName"] = lastName;
        
        initialiseUser(user, type: UserType.DEFAULT);
        
        /*user["friends"] = NSArray();
        user["viewHistory"] = NSArray();
        user["likedPosts"] = NSMutableArray();*/
        
        user.signUpInBackgroundWithBlock( {(succeeded: Bool, error: NSError!) in
            if (error == nil) {
                //success!
                //sees if user has pending items to process
                //ServerInteractor.initialUserChecks();
                //user's first notification
                ServerInteractor.postDefaultNotif("Welcome to InsertAppName! Thank you for signing up for our app!");
                signController.successfulSignUp();
                
            } else {
                //var errorString: String = error.userInfo["error"] as String;
                var errorString = error.localizedDescription;
                //display this error string to user
                //send some sort of notif to refresh screen
                signController.failedSignUp(errorString);
            }
        });
        return true;
    }
    
    class func initialiseUser(user: PFUser, type: UserType) {
        user["friends"] = NSArray();
        user["viewHistory"] = NSArray();
        user["likedPosts"] = NSMutableArray();
        user["userType"] = type.toRaw();
        user["numPosts"] = 0;
        user["followings"] = []
    }
    
    class func loginUser(username: String, password: String, sender: NewLoginViewController)->Bool {
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser!, error: NSError!) in
            var logController: NewLoginViewController = sender;
            if (user) {
                //successful log in
                //ServerInteractor.initialUserChecks();
                logController.successfulLogin();
            }
            else {
                //login failed
                //var errorString: String = error.userInfo["error"] as String;
                var errorString = error.localizedDescription;
                logController.failedLogin(errorString);
            }
        });
        return true;
    }
    //called when app starts + not anon user
    class func updateUser(sender: NSObject) {
        PFUser.currentUser().fetchInBackgroundWithBlock({(user: PFObject!, error: NSError!)->Void in
            var start: StartController = sender as StartController;
            if (error == nil) {
               // ServerInteractor.initialUserChecks();
                start.approveUser();
            }
            else {
                start.stealthUser();
            }
        });
    }
    
    
    //loggin in with facebook
    class func loginWithFacebook(sender: NSObject) {
        //whats permissions
        //permissions at https://developers.facebook.com/docs/facebook-login/permissions/v2.0
        //sample permissions: ["user_about_me", "user_relationships", "user_birthday", "user_location"]
        let permissions: [AnyObject]? = ["user_about_me", "user_relationships", "user_friends"];
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            var logController: NewLoginViewController = sender as NewLoginViewController;
            if (error != nil) {
                NSLog("Error message: \(error!.description)");
            } else if !user {
                logController.failedLogin("Uh oh. The user cancelled the Facebook login.");
            } else if user.isNew {
                //logController.failedLogin("User signed up and logged in through Facebook!")
                self.initialiseUser(user, type: UserType.FACEBOOK)
                /*user["friends"] = NSArray();
                user["viewHistory"] = NSArray();*/
                // ServerInteractor.initialUserChecks();
                //user's first notification
                
                //https://parse.com/questions/how-can-i-find-parse-users-that-are-facebook-friends-with-the-current-user
                FBRequestConnection.startForMeWithCompletionHandler({(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) in
                    if (error == nil) {
                        PFUser.currentUser()["personFirstName"] = result["first_name"];
                        PFUser.currentUser()["personLastName"] = result["last_name"];
                        PFUser.currentUser()["fbID"] = result["id"];
                        
                        ServerInteractor.setRandomUsernameAndSave((result["first_name"] as String).lowercaseString);
                    }
                    });
                
                
                user.saveEventually();
                //logController.successfulLogin();
                //logController.performSegueWithIdentifier("SetUsernameSegue", sender: logController)
                logController.facebookLogin()
                
                //var userID = userData.name
                //userNameLabel.text = ServerInteractor.getUserName()
                

                //var request: FBRequest = FBRequest.requestForMe();

                //var request3 = FBRequest.requestForMe();

                /*request3.startWithCompletionHandler({
                    (connection: FBRequestConnection!, result: NSObject!, error: NSError!) -> Void in
                    if (!error) {
                        var userData: NSDictionary = result as NSDictionary;
                        var userName: String = userData["name"] as String;
                    }
                });*/
                //var request = FBRequest.requestForMe();
               // var request = PF_FBRequest.requestForMe();
                //PFFacebookUtils.session();
                
            } else {
                FBRequestConnection.startForMeWithCompletionHandler({(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) in
                    if (error == nil) {
                        PFUser.currentUser()["personFirstName"] = result["first_name"];
                        PFUser.currentUser()["personLastName"] = result["last_name"];
                        PFUser.currentUser()["fbID"] = result["id"];
                        PFUser.currentUser().saveInBackground();
                    }
                });
                //logController.failedLogin("User logged in through Facebook!")
                //ServerInteractor.initialUserChecks();
                logController.successfulLogin();
            }
        });
    }
    class func setRandomUsernameAndSave(firstName: String) {
        
        var query: PFQuery = PFQuery(className: "SearchTerm");
        query.whereKey("term", equalTo: firstName);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
                if (error==nil) {
                    if (objects.count > 0) {
                        var termObj = objects[0] as PFObject
                        var termCount = termObj["count"] as Int;
                        PFUser.currentUser().username = "_"+firstName + String(termCount);
                        termObj.incrementKey("count");
                        PFUser.currentUser().saveInBackground();
                        termObj.saveInBackground();
                    }
                    else {
                        PFUser.currentUser().username = "_"+firstName;
                        ServerInteractor.makeNewTerm(firstName);
                        PFUser.currentUser().saveInBackground();
                    }
                    ServerInteractor.postDefaultNotif("Welcome to InsertAppName! Thank you for signing up for our app!");
                } else {
                    NSLog("Query for my terms failed")
                }
        });
    }


    //logged in as anonymous user does NOT count
    //use this to check whether to go to signup/login screen or directly to home
    class func isUserLogged()->Bool {
        if (PFUser.currentUser() != nil) {
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
            if (error != nil) {
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
    //used in friend display panels to handle my user screen vs other user screens
    class func getCurrentUser()->FriendEncapsulator {
        return FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());
    }
    //------------------Image Post related methods---------------------------------------
    
    
    class func extractStrings(description: String)->Array<String> {
        
        var retList: Array<String> = [];
        var error: NSError?;
        
        var pattern = "(#.+?\\b)|(.+?(?=#|$))";
        var regex: NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.fromMask(0), error: &error);
        
        var matches = regex.matchesInString(description, options: NSMatchingOptions.fromRaw(0)!, range: NSRange(location: 0, length: countElements(description))) as [NSTextCheckingResult];
        
        var attributedStringPiece: NSAttributedString;
        for match in matches {
            //var piece = aString.substringWithRange();
            var individualString: String = ((description as NSString).substringFromIndex(match.range.location) as NSString).substringToIndex(match.range.length);
            if (individualString.hasPrefix("#")) {
                retList.append((individualString as NSString).substringFromIndex(1));
            }
        }
        return retList;
    }
    
    //separates + processes label string, and also uploads labels to server
    class func separateLabels(labels: String, labelsFromDescription: Array<String>)->Array<String> {
        var arr = labels.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ", #"));
        arr = arr.filter({(obj: String)->Bool in obj != ""});
        
        for otherLabel in labelsFromDescription {
            if (!contains(arr, otherLabel)) {
                arr.append(otherLabel);
            }
        }
        
        
        var query = PFQuery(className: "SearchTerm");
        query.whereKey("term", containedIn: arr);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                var foundLabel: String;
                for object:PFObject in objects as [PFObject] {
                    foundLabel = object["term"] as String;
                    NSLog("\(foundLabel) already exists as label, incrementing")
                    object.incrementKey("count");
                    object.saveInBackground();
                    arr.removeAtIndex(find(arr, foundLabel)!);
                }
                //comment below to force use of only our labels (so users cant add new labels?)
                for label: String in arr {
                    ServerInteractor.makeNewTerm(label);
                }
            }
            else {
                NSLog("Error: Querying for labels failed");
            }
        });
        
        
        return arr;
    }
    class func makeNewTerm(label: String) {
        NSLog("Adding new label \(label)")
        var newLabel = PFObject(className: "SearchTerm");
        newLabel["term"] = label;
        newLabel["count"] = 1;
        newLabel.ACL.setPublicReadAccess(true);
        newLabel.ACL.setPublicWriteAccess(true);
        newLabel.saveInBackground();
    }
    
    
    //used by certain classes to resize the user icon to the correct specifications
    class func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        var rect: CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image.drawInRect(rect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    class func preprocessImages(images: Array<UIImage>)->Array<UIImage> {
        var individualRatio: Float;
        var width: Int;
        var height: Int;
        var newImgList: Array<UIImage> = [];
        var newSize: CGSize;
        var cropRect = CGRectMake(CGFloat(FULLSCREEN_WIDTH / 2), CGFloat(FULLSCREEN_HEIGHT / 2), CGFloat(FULLSCREEN_WIDTH), CGFloat(FULLSCREEN_HEIGHT));
        for (index, image: UIImage) in enumerate(images) {
            NSLog("Current image: W\(image.size.width) H\(image.size.height)")
            individualRatio = Float(image.size.width) / Float(image.size.height);
            var outputImg: UIImage?;
            if (CGFloat(image.size.height) > FULLSCREEN_HEIGHT && CGFloat(individualRatio) > WIDTH_HEIGHT_RATIO) {
                //this image is horizontal, so we resize image height to match
                newSize = CGSize(width: CGFloat(image.size.width) * FULLSCREEN_HEIGHT / CGFloat(image.size.height), height: FULLSCREEN_HEIGHT);
                UIGraphicsBeginImageContext(newSize);
                image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
                outputImg = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
                UIGraphicsEndImageContext();
            }
            else if (CGFloat(image.size.width) > FULLSCREEN_WIDTH && CGFloat(individualRatio) < WIDTH_HEIGHT_RATIO) {
                //this image is vertical, so we resize image width to match
                newSize = CGSize(width: FULLSCREEN_WIDTH, height: CGFloat(image.size.height) * FULLSCREEN_WIDTH / CGFloat(image.size.width));
                UIGraphicsBeginImageContext(newSize);
                image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
                outputImg = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
                UIGraphicsEndImageContext();
            }
            else {
                newImgList.append(image);
                continue;
            }
            newImgList.append(outputImg!);
            /*NSLog("Output image: W\(outputImg!.size.width) H\(outputImg!.size.height)")
            var imageRef = CGImageCreateWithImageInRect(outputImg!.CGImage, cropRect);
            var retImg: UIImage = UIImage(CGImage: imageRef);
            CGImageRelease(imageRef);
            NSLog("Final image: W\(retImg.size.width) H\(retImg.size.height)")
            newImgList.append(retImg);*/
        }
        return newImgList;
    }
    class func uploadImage(imgs: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        var exclusivity = PostExclusivity.EVERYONE;
        if (isAnonLogged()) {
            return;
        }
        else {
            //do preprocessing here to resize image to rendering specifications-WORK
            
            var images = preprocessImages(imgs);
            
            
            //var data = UIImagePNGRepresentation(images[0]);
            
            //end
            
            
            
            var newPost = ImagePostStructure(images: images, description: description, labels: labels, looks: looks);
            var sender = PFUser.currentUser().username;     //in case user logs out while object is still saving
            /*newPost.myObj.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError!)->Void in
                NSLog("What");
                });*/
            PFUser.currentUser().incrementKey("numPosts")
            PFUser.currentUser().saveEventually();

            newPost.myObj.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!)->Void in
                if (succeeded && error == nil) {
                    var myUser: PFUser = PFUser.currentUser();
                    if (!(myUser["userIcon"])) {
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
                    NSLog("Soem error of some sort");
                }
            });
        }
    }
    
    class func removePost(post: ImagePostStructure) {
        post.myObj.deleteInBackground();
    }
    
    //helper function to convert an array of ImagePostStructures into an array of its objectID's
    class func convertPostToID(input: Array<ImagePostStructure?>)->NSMutableArray {
        var output = NSMutableArray();
        for post: ImagePostStructure? in input {
            if (post != nil) {
                output.addObject(post!.myObj.objectId);
            }
        }
        return output;
    }
    class func appendToLikedPosts(id: String) {
        if (PFUser.currentUser()["likedPosts"] == nil) {
            NSLog("Something's wrong bro")
        }
        var likedPosts = PFUser.currentUser()["likedPosts"] as Array<String>;
        var likedPostsArray: NSMutableArray = NSMutableArray(array: likedPosts);
        likedPostsArray.insertObject(id, atIndex: 0)
        PFUser.currentUser()["likedPosts"] = likedPostsArray
        PFUser.currentUser().saveInBackground()
    }
    class func removeFromLikedPosts(id: String) {
        var likedPostsArray = PFUser.currentUser()["likedPosts"] as NSMutableArray
        likedPostsArray.removeObject(id);
        PFUser.currentUser()["likedPosts"] = likedPostsArray
        PFUser.currentUser().saveInBackground()
    }
    class func likedBefore(id: String)->Bool {
        if (PFUser.currentUser()["likedPosts"] == nil) {
            PFUser.currentUser()["likedPosts"] = NSArray();
            PFUser.currentUser().saveEventually();
            return false;
        }
        else {
            var likedPostsArray = PFUser.currentUser()["likedPosts"] as Array<String>;
            if (contains(likedPostsArray, id)) {
                return true;
            }
            return false;
        }
    }
    
    class func getLikedPosts(skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void) {
        var postsToGet = user.friendObj!["likedPosts"] as Array<String>;
        //var postsToGet = PFUser.currentUser()["likedPosts"] as Array<String>;
        //postsToGet = Array(postsToGet[skip...(skip + loadCount)])
        var oldCPosts = postsToGet as NSArray;
        //postsToGet = stupidArray
        if (oldCPosts.count - skip >= loadCount) {
            oldCPosts = oldCPosts.subarrayWithRange(NSRange(location: skip, length: loadCount))
        } else {
            oldCPosts = oldCPosts.subarrayWithRange(NSRange(location: skip, length: oldCPosts.count - skip))
        }
        var query = PFQuery(className:"ImagePost")
        query.whereKey("objectId", containedIn: oldCPosts)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error==nil) {
                notifyQueryFinish(objects.count);
                    var post: ImagePostStructure?;
                    for (index, object) in enumerate(objects!) {
                        post = ImagePostStructure.dequeueImagePost(object as PFObject);
                        var realIndex: Int = find(oldCPosts as Array<String>, object.objectId)!;
                        post!.loadImage(finishFunction, index: realIndex);
                    }
                } else {
                    NSLog("oh no!")
                }
            }
    }

    //return ImagePostStructure(image, likes)
    //counter = how many pages I've seen (used for pagination)
    //this method DOES fetch the images along with the data
    //class func getPost(friendsOnly: Bool, finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, sender: HomeFeedController, excludes: Array<ImagePostStructure?>) {
        
    class func getPost(loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)  {
        
        
        //query
        var query = PFQuery(className:"ImagePost")
        //query.skip = skip * POST_LOAD_COUNT;
        query.limit = POST_LOAD_COUNT;
        query.orderByDescending("createdAt");
        
        var excludeList = convertPostToID(excludes);

        if (!isAnonLogged()) {
            excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray));
            query.whereKey("author", notEqualTo: PFUser.currentUser().username);
        }

        /*
        if (friendsOnly && !isAnonLogged()) {
            query.whereKey("author", containedIn: (PFUser.currentUser()["friends"] as NSArray));
            //query.whereKey("objectId", notContainedIn: excludeList);
            //both friends + everyone marked feed from your friends show up here, as long as your friend posted
            //query.whereKey("exclusive", equalTo: PostExclusivity.FRIENDS_ONLY.toRaw()); <--- leave this commented
            if (!isAnonLogged()) {
                excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray))
            }
        }
        else {
            //must be an everyone-only post to show in popular feed
            query.whereKey("exclusive", equalTo: PostExclusivity.EVERYONE.toRaw());
            if (!isAnonLogged()) {
                excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray))
            }
            //query.whereKey("objectId", notContainedIn: excludeList);
        }*/
        query.whereKey("objectId", notContainedIn: excludeList);
        //query addAscending/DescendingOrder for extra ordering:
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // The find succeeded.
                // Do something with the found objects
                notifyQueryFinish(objects.count);
                
                var post: ImagePostStructure?;
                for (index, object) in enumerate(objects!) {
                    post = ImagePostStructure.dequeueImagePost((object as PFObject));
                    post!.loadImage(finishFunction, index: index);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
        //return returnList;
    }
    class func resetViewedPosts() {
        PFUser.currentUser()["viewHistory"] = NSArray();
        PFUser.currentUser().saveEventually();
    }
    //returns a list of my submissions (once again restricted by POST_LOAD_COUNT
    //does NOT autoload the image with the file
    //return reference to PFFile as well - use to load files later on
    class func getSubmissions(skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)  {
        var query = PFQuery(className:"ImagePost")
        query.whereKey("author", equalTo: user.getName({}));
        query.limit = loadCount;
        query.skip = skip;
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // The find succeeded.
                
                notifyQueryFinish(objects.count);
                
                // Do something with the found objects
                var post: ImagePostStructure?;
                for (index, object) in enumerate(objects!) {
                    post = ImagePostStructure.dequeueImagePost(object as PFObject);
                    post!.loadImage(finishFunction, index: index);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
    }
    class func getSubmissionsForSuggest(loadCount: Int, user: FriendEncapsulator, userIndex: Int,  notifyQueryFinish: (Int, Int)->Void, finishFunction: (Int, ImagePostStructure, Int)->Void)  {
        var query = PFQuery(className:"ImagePost")
        query.whereKey("author", equalTo: user.username);
        query.limit = loadCount;
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // Do something with the found objects
                notifyQueryFinish(userIndex, objects.count);
                var post: ImagePostStructure?;
                for (index, object) in enumerate(objects!) {
                    post = ImagePostStructure.dequeueImagePost(object as PFObject);
                    post!.loadImage({
                        (img: ImagePostStructure, index: Int) in
                        finishFunction(userIndex, img, index);
                        }, index: index);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }

    }
    
    class func getSearchPosts(skip: Int, loadCount: Int, term: String, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)  {
        var query = PFQuery(className:"ImagePost")
        var twoTermz = term.lowercaseString;
        query.whereKey("labels", containsAllObjectsInArray: [twoTermz]);
        query.limit = loadCount;
        query.skip = skip;
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // The find succeeded.
                
                notifyQueryFinish(objects.count);
                
                // Do something with the found objects
                var post: ImagePostStructure?;
                for (index, object) in enumerate(objects!) {
                    post = ImagePostStructure.dequeueImagePost(object as PFObject);
                    post!.loadImage(finishFunction, index: index);
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }
    }

    
    class func readPost(post: ImagePostStructure) {
        var postID = post.myObj.objectId;
        PFUser.currentUser().addUniqueObject(postID, forKey: "viewHistory");
        PFUser.currentUser().saveEventually();
        
    }
    
    //------------------Notification related methods---------------------------------------
    class func processNotification(targetUserName: String, targetObject: PFObject)->Array<AnyObject?>? {
        return processNotification(targetUserName, targetObject: targetObject, controller: nil);
    }
    class func processNotification(targetUserName: String, targetObject: PFObject, controller: UIViewController?)->Array<AnyObject?>? {
        
        var query: PFQuery = PFUser.query();
        query.whereKey("username", equalTo: targetUserName)
        var currentUserName = PFUser.currentUser().username;
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
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
            else if (controller != nil) {
                if(objects.count == 0) {
                    (controller! as FriendTableViewController).notifyFailure("No such user exists!");
                }
                else if (error != nil) {
                    //controller.makeNotificationThatFriendYouWantedDoesntExistAndThatYouAreVeryLonely
                    (controller! as FriendTableViewController).notifyFailure(error.localizedDescription as String);
                }
            }
        });
        return nil; //useless statement to suppress useless stupid xcode thing
    }
    
    class func getNotifications(controller: NotifViewController) {
        if (isAnonLogged()) {
            if (controller.notifList.count == 0) {
                controller.notifList.append(InAppNotification(message: "To see your notifications sign up and make an account!"));
            }
            return;
        }
        var query = PFQuery(className:"Notification")
        query.whereKey("recipient", equalTo: PFUser.currentUser().username);
        //want most recent first
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // The find succeeded.
                // Do something with the found objects
                var object: PFObject;
                if (objects.count < controller.notifList.count) {
                    var stupidError = controller.notifList.count - objects.count
                    //var counter = objects.count - controller.notifList.count
                    //objects = controller.notifList[0...objects.count - counter]
                    //controller.notifList = controller.notifList[0...stupidError] as Array<InAppNotification?>
                    for index: Int in 0..<stupidError {
                        controller.notifList.removeLast()
                        //object = objects[0] as PFObject;
                    }
                    if (controller.notifList.count == 0) {
                        controller.tableView.reloadData();
                    }
                }
                for index:Int in 0..<objects.count {
                    object = objects![index] as PFObject;
                    if (index >= NOTIF_COUNT) {
                        if(object["viewed"]) {
                            object.deleteInBackground();
                            continue;
                        }
                    }
                    
                                        
                    if(index >= controller.notifList.count) {
                        var item = InAppNotification(dataObject: object);
                        //weird issue #7 error happening here, notifList is NOT dealloc'd (exists) WORK
                        //EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
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
    class func postFollowerNotif(friendName: String, controller: UIViewController) {
        if (friendName == "") {
            (controller as UserProfileViewController).notifyFailure("Please fill in a name");
            return;
        }
        
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FOLLOWER_NOTIF.toRaw();
        ServerInteractor.processNotification(friendName, targetObject: notifObj, controller: controller);
        
    }
    //you have just accepted your friend's invite; your friend now gets informed that you are now his friend <3
    //note: the func return type is to suppress some stupid thing that happens when u have objc stuff in your swift header
    /*class func postFriendAccept(friendName: String)->Array<AnyObject?>? {
        //first, query + find the user
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FRIEND_ACCEPT.toRaw();
        //notifObj.saveInBackground();
        
        ServerInteractor.processNotification(friendName, targetObject: notifObj);
        return nil;
    }*/
    //call this method when either accepting a friend inv or receiving a confirmation notification
    class func addAsFriend(friendName: String)->Array<NSObject?>? {
        NSLog("Wrong method being called, please remove!")
        PFUser.currentUser().addUniqueObject(friendName, forKey: "friends");
        PFUser.currentUser().saveEventually();
        return nil;
    }
    
    //follow a user
    class func addAsFollower(followerName: String) {
        if (contains(PFUser.currentUser()["followings"] as Array<String>, followerName)) {
            return;
        } else {
            var friendObj: PFObject = PFObject(className: "Friendship")
            friendObj.ACL.setPublicReadAccess(true)
            friendObj.ACL.setPublicWriteAccess(true)
            friendObj["follower"] = PFUser.currentUser().username
            friendObj["following"] = followerName
            friendObj.saveEventually()
            var followingsArray: NSMutableArray = PFUser.currentUser()["followings"] as NSMutableArray;
            followingsArray.insertObject(followerName, atIndex: 0)
            PFUser.currentUser()["followings"] = followingsArray
            PFUser.currentUser().saveEventually()
        }
    }
    class func removeAsFollower(followingName: String) {
        var followingsArray: NSMutableArray = PFUser.currentUser()["followings"] as NSMutableArray
        followingsArray.removeObject(followingName)
        PFUser.currentUser()["followings"] = followingsArray
        PFUser.currentUser().saveEventually()
        var query = PFQuery(className: "Friendship");
        query.whereKey("follower", equalTo: PFUser.currentUser().username)
        query.whereKey("following", equalTo: followingName)
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                if (objects.count > 0) {
                    (objects[0] as PFObject).deleteInBackground();
                }
            }
        });

    }
    
    class func findFollowers(followerName: String, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        var query = PFQuery(className: "Friendship");
        query.whereKey("following", equalTo: followerName)
        var followerList: Array<FriendEncapsulator?> = [];
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
                //var followerList: Array<FriendEncapsulator?>  = listToAddTo
                for object in objects {
                    var following = object["follower"] as String
                    var friend = FriendEncapsulator.dequeueFriendEncapsulator(following)
                    followerList.append(friend)
                }
                retFunction(retList: followerList)
            });
    }
    
    class func findFollowing(followerName: String, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        var followingList: Array<FriendEncapsulator?> = []
        for object in PFUser.currentUser()["followings"] as Array<String> {
            var following = FriendEncapsulator.dequeueFriendEncapsulator(object)
            followingList.append(following)
        }
        retFunction(retList: followingList)
        
    }
    
    class func findNumFollowing(followerName: String, retFunction: (Int)->Void) {
        
        retFunction(PFUser.currentUser()["followings"].count)
    }

    class func findNumFollowers(followerName: String, retFunction: (Int)->Void) {
        var query = PFQuery(className: "Friendship");
        query.whereKey("following", equalTo: followerName)
        var followerList: Array<FriendEncapsulator?> = [];
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            //var followerList: Array<FriendEncapsulator?>  = listToAddTo
            for object in objects {
                var following = object["follower"] as String
                var friend = FriendEncapsulator.dequeueFriendEncapsulator(following)
                followerList.append(friend)
            }
            retFunction(followerList.count)
            //return (followerList.count)
        });
        //return followerList.count
    }
    
    //returns if I am already following user X
    class func amFollowingUser(followingName: String, retFunction: (Bool)->Void) {
        
        if(contains(PFUser.currentUser()["followings"] as Array<String>, followingName)) {
            retFunction(true)
        } else {
            return retFunction(false)
        }
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
            
            
            var query: PFQuery = PFUser.query();
            query.whereKey("username", equalTo: friendName)
            var currentUserName = PFUser.currentUser().username;
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if (objects.count > 0) {
                    var targetUser = objects[0] as PFUser;
                    var breakupObj = PFObject(className:"BreakupNotice")
                    breakupObj["sender"] = PFUser.currentUser().username;
                    breakupObj["recipient"] = friendName;
                    
                    breakupObj.ACL.setReadAccess(true, forUser: targetUser)
                    breakupObj.ACL.setWriteAccess(true, forUser: targetUser)
                    
                    breakupObj.saveInBackground();
                    //send notification object
                }
            });
        }
        return nil;
    }
    
    class func removeFollower(friendName: String, isHeartBroken: Bool)->Array<NSObject?>? {
        PFUser.currentUser().removeObject(friendName, forKey: "following");
        PFUser.currentUser().saveInBackground();
        if (!isHeartBroken) {
            //do NOT use processNotification - we don't want to post a notification
            
            
            var query: PFQuery = PFUser.query();
            query.whereKey("username", equalTo: friendName)
            var currentUserName = PFUser.currentUser().username;
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if (objects.count > 0) {
                    var targetUser = objects[0] as PFUser;
                    var breakupObj = PFObject(className:"BreakupNotice")
                    breakupObj["sender"] = PFUser.currentUser().username;
                    breakupObj["recipient"] = friendName;
                    
                    breakupObj.ACL.setReadAccess(true, forUser: targetUser)
                    breakupObj.ACL.setWriteAccess(true, forUser: targetUser)
                    
                    breakupObj.saveInBackground();
                    //send notification object
                }
                });
        }
        return nil;
    }

    
    class func getSuggestedFollowers(numToReturn: Int, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        //screw it I'm going to make it random 3 followers for now
        //let NUM_FOLLOWERS_TO_QUERY: Int32 = 3;
        
        var toRet: Array<FriendEncapsulator?> = [];
        
        var query = PFUser.query();
        query.whereKey("userType", containedIn: RELEVANT_TYPES);
        query.whereKey("numPosts", greaterThan: 1);
        
        //-----add orderby type (rank by popularity?)-------------WORK NEED
        //query......
        //------------------------
        
        
        query.countObjectsInBackgroundWithBlock({(result: Int32, error: NSError!) in
            if (error == nil) {
                if (result == 0) {
                    
                }
                else {
                    var nums = 0;
                    for i in 0..<numToReturn {
                        var query = PFUser.query();
                        query.whereKey("userType", containedIn: RELEVANT_TYPES);
                        query.whereKey("numPosts", greaterThan: 1);
                        //change random to be hierarched (i.e. biased toward top) as to weigh results toward more popular users
                        //make this unique numbers
                        query.skip = random() % Int(result);
                        //WORK NEED
                        query.limit = 1;
                        query.findObjectsInBackgroundWithBlock({
                            (objects: [AnyObject]!, error: NSError!) in
                            for index: Int in 0..<objects.count {
                                toRet.append(FriendEncapsulator.dequeueFriendEncapsulator(objects[index] as PFUser));
                            }
                            nums += 1;
                            if (nums == numToReturn) {
                                retFunction(retList: toRet);
                            }
                        })
                    }
                }
            }
        });
    }
    
    //not currently used, but might be helpful later on/nice to have a default version
    class func getFriends()->Array<FriendEncapsulator?> {
        return getFriends(FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser()));
    }
    
    //gets me a list of my friends!
    //used by friend table loader
    class func getFriends(user: FriendEncapsulator)->Array<FriendEncapsulator?> {
        var unwrapUser = user.friendObj;
        var returnList: Array<FriendEncapsulator?> = [];
        var friendz: NSArray;
        if ((unwrapUser!.allKeys() as NSArray).containsObject("friends")) {
            //if this runs, the code will break catastrophically, just initialize "friends" with registration
            friendz = unwrapUser!["friends"] as NSArray;
        }
        else {
            NSLog("Updating an old account to have friends");
            friendz = NSArray();
            unwrapUser!["friends"] = NSArray()
            unwrapUser!.saveInBackground();
        }
        var friend: String;
        for index in 0..<friendz.count {
            friend = friendz[index] as String;
            returnList.append(FriendEncapsulator.dequeueFriendEncapsulator(friend));
        }
        return returnList;
    }
    
    //checks that user should do whenever starting to use app on account
    /*class func initialUserChecks() {
        //check and see if user has any notice for removal of friends
        var query = PFQuery(className: "BreakupNotice");
        query.whereKey("recipient", equalTo: PFUser.currentUser().username);
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in 
            NSLog("No explanation");
            if (!error) {
                var object: PFObject;
                
                if (objects.count == 0 ){
                    ServerInteractor.checkAcceptNotifs();
                    return;
                }
                
                for index: Int in 0..<objects.count {
                    var last = (index == objects.count - 1);
                    object = objects[index] as PFObject;
                    ServerInteractor.removeFriend(object["sender"] as String, isHeartBroken: true);
                    
                    
                    var query = PFQuery(className: "Notification");
                    query.whereKey("sender", equalTo: object["sender"] as String);
                    query.whereKey("createdAt", lessThan: object.createdAt);
                    //query.lessThan("createdAt", object["createdAt"]);
                    query.findObjectsInBackgroundWithBlock({(objects: [AnyObject]!, error: NSError!) -> Void in
                        for index: Int in 0..<objects.count {
                            objects[index].deleteInBackgroundWithBlock({
                                (succeeded: Bool, error: NSError!)->Void in
                                    if (last) {
                                        object.deleteInBackground();
                                        ServerInteractor.checkAcceptNotifs();
                                    }
                                });
                            }
                    });
                }
            }
            else {
                NSLog("Error: Could not fetch");
            }
        });
    }*/
    //------------------Search methods---------------------------------------
    class func getSearchTerms(term: String, initFunc: (Int)->Void, receiveFunc: (Int, String)->Void, endFunc: ()->Void) {
        var twoTermz = term.lowercaseString;
        var query = PFQuery(className: "SearchTerm");
        query.whereKey("term", containsString: twoTermz);
        //query.orderByDescending("importance")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!)->Void in
            initFunc(objects.count);
            var content: String;
            for index: Int in 0..<objects.count {
                content = (objects[index] as PFObject)["term"] as String;
                receiveFunc(index, content);
            }
            endFunc();
        });
    }
    class func getSearchUsers(term: String, initFunc: (Int)->Void, receiveFunc: (Int, String)->Void, endFunc: ()->Void) {
        var twoTermz = term.lowercaseString;
        var query = PFUser.query();
        query.whereKey("username", containsString: twoTermz);
        query.whereKey("userType", containedIn: RELEVANT_TYPES);
        //query.orderByDescending("importance")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!)->Void in
            initFunc(objects.count);
            var content: String;
            for index: Int in 0..<objects.count {
                content = (objects[index] as PFObject)["username"] as String;
                receiveFunc(index, content);
            }
            endFunc();
            });
    }
    //http://stackoverflow.com/questions/24752627/accessing-ios-address-book-with-swift-array-count-of-zero
    class func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    class func getSearchContacts(initFunc: (Int)->Void, receiveFunc: (Int, String)->Void, endFunc: ()->Void) {
        var addressBook: ABAddressBookRef?;
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            NSLog("Requesting authorization")
            var errorRef: Unmanaged<CFError>? = nil
            addressBook = ServerInteractor.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    ServerInteractor.getContactNames(initFunc, receiveFunc, endFunc)
                }
                else {
                    NSLog("error")
                }
                })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            NSLog("Access denied")
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            ServerInteractor.getContactNames(initFunc, receiveFunc, endFunc);
        }
    }
    class func getContactNames(initFunc: (Int)->Void, receiveFunc: (Int, String)->Void, endFunc: ()->Void) {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        //println("records in the array \(contactList.count)")
        
        var arrayOfQueries: Array<PFQuery> = [];
        
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            
            var fName: AnyObject = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty).takeRetainedValue();
            var firstName: String = fName as NSString;
            
            var lName: AnyObject = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty).takeRetainedValue();
            var lastName: String = lName as NSString;
            //kABPersonPhoneProperty, kABPersonEmailProperty
            
            //var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
            //var firstName: String = "";
            //var lastName: String = "";
            //firstName = fName as NSString;
            //lastName = lName as NSString;
            //println ("contactName \(contactName)")
            var query: PFQuery = PFUser.query();
            query.whereKey("personFirstName", equalTo: fName);
            query.whereKey("personLastName", equalTo: lName);
            arrayOfQueries.append(query);
        }
        
        var combinedQuery = PFQuery.orQueryWithSubqueries(arrayOfQueries);
        
        combinedQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            initFunc(objects.count);
            for index: Int in 0..<objects.count {
                var content = (objects[index] as PFObject)["username"] as String;
                //var friend = FriendEncapsulator(friendName: content);
                receiveFunc(index, content);
            }
            endFunc();
        });
    }
    
    class func getFBFriendUsers(initFunc: (Int)->Void, receiveFunc: (Int, String)->Void, endFunc: ()->Void) {
        if (PFUser.currentUser()["fbID"] == nil) {
            NSLog("This account is not linked to fb!");
            initFunc(0);
            endFunc();
            return;
        }
        /*if ((FBSession.activeSession().permissions as NSArray).indexOfObject("user_friends") == NSNotFound) {
            FBSession.activeSession().requestNewReadPermissions(["user_friends"], completionHandler: {
                (session: FBSession!, error: NSError!) in
                if (error == nil) {
                    if ((FBSession.activeSession().permissions as NSArray).indexOfObject("user_friends") == NSNotFound) {
                        //permissions not found!
                        NSLog("FB Permissions rejected");
                    }
                    else {
                        //all good, continue
                        self.lookforFBFriendsAndSet(initFunc, receiveFunc: receiveFunc, endFunc: endFunc);
                    }
                }
                else {
                    NSLog("FB Requesting error, handling it!");
                }
            });

        }
        else {*/
        FBRequestConnection.startForMyFriendsWithCompletionHandler({
            (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) in
            if (error == nil) {
                var friendObjs = result.objectForKey("data") as NSArray;
                var friendIds = NSMutableArray(capacity: friendObjs.count);
                for friendObject in friendObjs {
                    friendIds.addObject(friendObject.objectForKey("id"));
                }
                var query: PFQuery = PFUser.query();
                query.whereKey("fbID", containedIn: friendIds);
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!) in
                    initFunc(objects.count);
                    for index: Int in 0..<objects.count {
                        var content = (objects[index] as PFObject)["username"] as String;
                        //var friend = FriendEncapsulator(friendName: content);
                        receiveFunc(index, content);
                    }
                    endFunc();
                });
            }
        });
    }
}
