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
        else if (username.rangeOfString(" ") != nil) {
            signController.failedSignUp("Usernames cannot contain spaces");
            return false;
        }
        else if (countElements(username) > 20) {
            signController.failedSignUp("Your username \(username) is too long. Usernames must be between 1-20 characters long.");
            return false;
        }
        else if (email == "") {
            signController.failedSignUp("You must specify an email.");
            return false;
        }
        else if (password == "") {
            signController.failedSignUp("You must specify a password.");
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
        user["personFullName"] = firstName + " " + lastName;
        
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
                ServerInteractor.postDefaultNotif("Welcome to FashionStash! Thank you for signing up for our app!");
                ServerInteractor.runOnAllInitialUser();
                //ImagePostStructure.unreadAllPosts();
                signController.successfulSignUp();
                
            } else {
                var message: String = "";
                if (error.code == 200) {
                    message = "Missing username!"
                }
                else if (error.code == 201) {
                    message = "Missing password!"
                }
                else if (error.code == 202) {
                    message = "A user with the username \(username) already exists.";
                }
                else if (error.code == 203) {
                    message = "A user with the email \(email) already exists.";
                }
                else if (error.code == 204) {
                    message = "An email must be specified to register an account.";
                }
                else {
                    message = "Encountered an error while trying to register. Please try again.\nError Details: " + error.localizedDescription
                }
                //var errorString: String = error.userInfo["error"] as String;
                //var errorString = error.localizedDescription;
                //display this error string to user
                //send some sort of notif to refresh screen
                signController.failedSignUp(message);
            }
        });
        return true;
    }
    
    class func initialiseUser(user: PFUser, type: UserType) {
        //user["friends"] = NSArray();
        user["viewHistory"] = NSArray();
        user["likedPosts"] = NSMutableArray();
        user["userType"] = type.rawValue;
        user["numPosts"] = 0;
        user["followings"] = NSMutableArray();
        user["followingIds"] = NSMutableArray();
        user["receivePush"] = true;
    }
    
    class func loginUser(username: String, password: String, sender: RealLoginViewController)->Bool {
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser!, error: NSError!) in
            var logController: RealLoginViewController = sender;
            if ((user) != nil) {
                //successful log in
                //ServerInteractor.initialUserChecks();
                //ImagePostStructure.unreadAllPosts();
                ServerInteractor.runOnAllInitialUser();
                logController.successfulLogin();
            }
            else {
                if (error != nil) {
                    if (error.code == 101) {
                        var msgString = "Invalid username/password!"
                        logController.failedLogin(msgString);
                    }
                    else {
                        var msgString = "Failed to authenticate user; please try again in a few seconds"
                        logController.failedLogin(msgString);
                    }
                }
                else {
                    var msgString = "Invalid username/password!"
                    logController.failedLogin(msgString);
                }
                //login failed
                //var errorString: String = error.userInfo["error"] as String;
                //var errorString = error.localizedDescription;
                //logController.failedLogin(errorString);
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
                ServerInteractor.runOnAllInitialUser();
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
        //let permissions: [AnyObject]? = ["user_about_me", "user_relationships", "user_friends"];
        PFFacebookUtils.logInWithPermissions(FB_PERMISSIONS, {
            (user: PFUser!, error: NSError!) -> Void in
            var logController: NewLoginViewController = sender as NewLoginViewController;
            if (error != nil) {
                NSLog("Error message: \(error!.description)");
            } else if (user == nil) {
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
                        PFUser.currentUser()["personFullName"] = (result["first_name"] as String) + " " + (result["last_name"] as String);
                        PFUser.currentUser()["fbID"] = result["id"];
                        
                        ServerInteractor.setRandomUsernameAndSave((result["first_name"] as String).lowercaseString);
                    }
                    });
                
                
                user.saveEventually();
                //logController.successfulLogin();
                //logController.performSegueWithIdentifier("SetUsernameSegue", sender: logController)
                //ImagePostStructure.unreadAllPosts();
                ServerInteractor.runOnAllInitialUser();
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
                NSLog("create a new FB user")
            } else {
                FBRequestConnection.startForMeWithCompletionHandler({(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) in
                    if (error == nil) {
                        PFUser.currentUser()["personFirstName"] = result["first_name"];
                        PFUser.currentUser()["personLastName"] = result["last_name"];
                        PFUser.currentUser()["personFullName"] = (result["first_name"] as String) + " " + (result["last_name"] as String);
                        PFUser.currentUser()["fbID"] = result["id"];
                        PFUser.currentUser().saveInBackground();
                    }
                });
                //logController.failedLogin("User logged in through Facebook!")
                //ServerInteractor.initialUserChecks();
                //ImagePostStructure.unreadAllPosts();
                ServerInteractor.runOnAllInitialUser(); NSLog("success to log in \(user.objectId)")
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
                    ServerInteractor.postDefaultNotif("Welcome to FashionStash! Thank you for signing up for our app!");
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
    
    class func getUserID()->String {
        return PFUser.currentUser().objectId;
    }
    
    //used in friend display panels to handle my user screen vs other user screens
    class func getCurrentUser()->FriendEncapsulator {
        return FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());
    }

    class func runOnAllInitialUser() {
        ImagePostStructure.unreadAllPosts();
        PFInstallation.currentInstallation().setObject(PFUser.currentUser(), forKey: "user");
        PFInstallation.currentInstallation().saveEventually();
    }

    //------------------Image Post related methods---------------------------------------
    
    
    class func extractStrings(description: String)->Array<String> {
        
        var retList: Array<String> = [];
        var error: NSError?;
        
        var pattern = "(#.+?\\b)|(.+?(?=#|$))";
        var regex: NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error: &error)!;
        
        var matches = regex.matchesInString(description, options: NSMatchingOptions.allZeros, range: NSRange(location: 0, length: countElements(description)));
        
        //var matches = regex.matchesInString(description, options: NSMatchingOptions.init(rawValue: 0)!, range: NSRange(location: 0, length: countElements(description))) //as Array<NSTextCheckingResult>;
        
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
        //remove duplicate labels here!
        
        var arrWithoutDuplicates: Array<String> = [];
        for otherLabel in arr {
            if (!contains(arrWithoutDuplicates, otherLabel)) {
                arrWithoutDuplicates.append(otherLabel);
            }
        }
        
        var query = PFQuery(className: "SearchTerm");
        query.whereKey("term", containedIn: arrWithoutDuplicates);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                var foundLabel: String;
                for object:PFObject in objects as [PFObject] {
                    foundLabel = object["term"] as String;
                    NSLog("\(foundLabel) already exists as label, incrementing")
                    object.incrementKey("count");
                    object.saveInBackground();
                    if let foundIndex = find(arrWithoutDuplicates, foundLabel) {
                        arrWithoutDuplicates.removeAtIndex(foundIndex);
                    }
                }
                //comment below to force use of only our labels (so users cant add new labels?)
                for label: String in arrWithoutDuplicates {
                    ServerInteractor.makeNewTerm(label);
                }
            }
            else {
                NSLog("Error: Querying for labels failed");
            }
        });
        
        
        return arrWithoutDuplicates;
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
    class func imageWithColorForSearch(color: UIColor, andHeight height: CGFloat)->UIImage {
        var rect = CGRectMake(0, 0, 1, height);
        UIGraphicsBeginImageContext(rect.size);
        var context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    class func cropImageSoNavigationWorksCorrectly(img: UIImage, frame: CGRect)->UIImage {
        var wRatio = frame.size.width / img.size.width;
        var hRatio = frame.size.height / img.size.height;
        NSLog("\(img.size.width) - \(img.size.height)")
        NSLog("\(frame.size.width) - \(frame.size.height)")
        var ratio = max(wRatio, hRatio);
        
        UIGraphicsBeginImageContext(frame.size);
        
        var imgNewWidth = ratio * img.size.width;
        var imgNewHeight = ratio * img.size.height;
        var leftMargin = (imgNewWidth - frame.size.width) / 2;
        var topMargin = (imgNewHeight - frame.size.height) / 2;
        img.drawInRect(CGRectMake(-leftMargin, -topMargin, imgNewWidth, imgNewHeight));
        NSLog("\(imgNewWidth) - \(imgNewHeight)")
        var finalImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return finalImg;
    }
    class func blurBackImage(img: UIImage)->UIImage {
        //var croppedPicture = cropImageSoNavigationWorksCorrectly(img, frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT))
        /*
        var ciContext = CIContext(options: nil);
        
        var imageToBlur = CIImage(CGImage: img.CGImage);
        //var transform = CGAffineTransformIdentity;
        //imageToBlur.imageByApplyingTransform(transform);
        var gaussianBlurFilter = CIFilter(name: "CIGaussianBlur");
        gaussianBlurFilter.setDefaults();
        gaussianBlurFilter.setValue(imageToBlur, forKey: kCIInputImageKey);
        var blurLevel = CGFloat(20.0);
        gaussianBlurFilter.setValue(NSNumber(float: Float(blurLevel)), forKey: "inputRadius");
        //var transform = CGAffineTransformIdentity;
        //var transformValue = NSValue(&transform, withObjCType: CGAffineTransform);
        //NSValue.value
        //gaussianBlurFilter.setValue(transformValue, forKey: "inputTransform")
        var result = gaussianBlurFilter.valueForKey(kCIOutputImageKey) as CIImage;
        var resultingRect = imageToBlur.extent();
        resultingRect.origin.x += blurLevel;
        resultingRect.origin.y += blurLevel;
        resultingRect.size.width -= blurLevel*2.0;
        resultingRect.size.height -= blurLevel*2.0;
        var cgImage = ciContext.createCGImage(result, fromRect: resultingRect)
        
        var backBlurredImage = UIImage(CGImage: cgImage);
        return backBlurredImage;*/
        return img.applyDarkEffect();
    }
    class func darkenImage(img: UIImage)->UIImage {
        return img.applyDarkEffect();
        /*var rect = CGRectMake(0, 0, img.size.width, img.size.height)
        UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height))
        var context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor);
        CGContextFillRect(context, rect);
        img.drawInRect(rect, blendMode: kCGBlendModeNormal, alpha: 0.55);
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;*/
    }
    class func cropImageSoWidthIs(img: UIImage, targetWidth: CGFloat)->UIImage {
        
        var widthHeightImgRatio = img.size.width / img.size.height;
        
        if (widthHeightImgRatio > CROP_WIDTH_HEIGHT_LIMIT_RATIO) { NSLog("widthHeightImgRatio: \(widthHeightImgRatio)")
            
            var croppedPicture = cropImageSoNavigationWorksCorrectly(img, frame: CGRectMake(0, 64, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT-124))
            /*
            var ciContext = CIContext(options: nil);
            
            var imageToBlur = CIImage(CGImage: croppedPicture.CGImage);
            //var transform = CGAffineTransformIdentity;
            //imageToBlur.imageByApplyingTransform(transform);
            var gaussianBlurFilter = CIFilter(name: "CIGaussianBlur");
            gaussianBlurFilter.setDefaults();
            gaussianBlurFilter.setValue(imageToBlur, forKey: kCIInputImageKey);
            var blurLevel = CGFloat(20.0);
            gaussianBlurFilter.setValue(NSNumber(float: Float(blurLevel)), forKey: "inputRadius");
            //var transform = CGAffineTransformIdentity;
            //var transformValue = NSValue(&transform, withObjCType: CGAffineTransform);
            //NSValue.value
            //gaussianBlurFilter.setValue(transformValue, forKey: "inputTransform")
            var result = gaussianBlurFilter.valueForKey(kCIOutputImageKey) as CIImage;
            var resultingRect = imageToBlur.extent();
            resultingRect.origin.x += blurLevel;
            resultingRect.origin.y += blurLevel;
            resultingRect.size.width -= blurLevel*2.0;
            resultingRect.size.height -= blurLevel*2.0;
            var cgImage = ciContext.createCGImage(result, fromRect: resultingRect)
            
            var backBlurredImage = UIImage(CGImage: cgImage);*/
            var backBlurredImage = ServerInteractor.blurBackImage(croppedPicture);
            
            //width is longer than my limit, I will display as a full image with blackspace
            var wRatio = targetWidth / img.size.width;
            //var hRatio = frame.size.height / img.size.height;
            var targetHeight = wRatio * img.size.height;
            NSLog("\(targetWidth)- \(targetHeight)")
            NSLog("\(img.size.width) - \(img.size.height)")
            NSLog("\(FULLSCREEN_WIDTH) - \(TRUE_FULLSCREEN_HEIGHT)")
            var rect = CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT);
            
            UIGraphicsBeginImageContext(CGSizeMake(FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT))
            //var context = UIGraphicsGetCurrentContext();
            //CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor);
            //CGContextFillRect(context, rect);
            //backBlurredImage.drawInRect(rect, blendMode: kCGBlendModeNormal, alpha: 0.55);
            backBlurredImage.drawInRect(rect, blendMode: kCGBlendModeNormal, alpha: 1.0);
            var rect2: CGRect = CGRect(x: 0, y: (TRUE_FULLSCREEN_HEIGHT - targetHeight) / 2.0, width: targetWidth, height: targetHeight);
            img.drawInRect(rect2)
            var newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage;
            //return ServerInteractor.imageWithImage(img, scaledToSize: CGSizeMake(targetWidth, targetHeight));
        }
        else {
            //i need to scale image to fit the screen dimensions!
            return cropImageSoNavigationWorksCorrectly(img, frame: CGRectMake(0, 64, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT-124));
        }
    }
    
    class func preprocessImages(images: Array<UIImage>)->Array<UIImage> {
        var individualRatio: Float;
        var width: Int;
        var height: Int;
        var newImgList: Array<UIImage> = [];
        var newSize: CGSize;
        var cropRect = CGRectMake(CGFloat(IMGSAVE_FULLSCREEN_WIDTH / 2), CGFloat(IMGSAVE_FULLSCREEN_HEIGHT / 2), CGFloat(IMGSAVE_FULLSCREEN_WIDTH), CGFloat(IMGSAVE_FULLSCREEN_HEIGHT));
        for (index, image: UIImage) in enumerate(images) {
            /*NSLog("Current image: W\(image.size.width) H\(image.size.height)")
            individualRatio = Float(image.size.width) / Float(image.size.height);
            var outputImg: UIImage?;
            if (CGFloat(image.size.height) > IMGSAVE_FULLSCREEN_HEIGHT && CGFloat(individualRatio) > WIDTH_HEIGHT_RATIO) {
                //this image is horizontal, so we resize image height to match
                newSize = CGSize(width: CGFloat(image.size.width) * IMGSAVE_FULLSCREEN_HEIGHT / CGFloat(image.size.height), height: IMGSAVE_FULLSCREEN_HEIGHT);
                UIGraphicsBeginImageContext(newSize);
                image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
                outputImg = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
                UIGraphicsEndImageContext();
            }
            else if (CGFloat(image.size.width) > IMGSAVE_FULLSCREEN_WIDTH && CGFloat(individualRatio) < WIDTH_HEIGHT_RATIO) {
                //this image is vertical, so we resize image width to match
                newSize = CGSize(width: IMGSAVE_FULLSCREEN_WIDTH, height: CGFloat(image.size.height) * IMGSAVE_FULLSCREEN_WIDTH / CGFloat(image.size.width));
                UIGraphicsBeginImageContext(newSize);
                image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
                outputImg = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
                UIGraphicsEndImageContext();
            }
            else {*/
            newImgList.append(image);
            continue;
            //}
            //newImgList.append(outputImg!);
            /*NSLog("Output image: W\(outputImg!.size.width) H\(outputImg!.size.height)")
            var imageRef = CGImageCreateWithImageInRect(outputImg!.CGImage, cropRect);
            var retImg: UIImage = UIImage(CGImage: imageRef);
            CGImageRelease(imageRef);
            NSLog("Final image: W\(retImg.size.width) H\(retImg.size.height)")
            newImgList.append(retImg);*/
        }
        return newImgList;
    }
    class func updatePost(post: ImagePostStructure, imgs: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        var images = preprocessImages(imgs);
        post.updatePost(imgs, description: description, labels: labels, looks: looks);
    }
    class func uploadImage(imgs: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>, finishFunction: (imgStruct: ImagePostStructure?)->Void) {
        var exclusivity = PostExclusivity.EVERYONE;
        if (isAnonLogged()) {
            finishFunction(imgStruct: nil)
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
                    if ((myUser["userIcon"]) == nil) {
                        //above may set to last submitted picture...? sometimes??
                        //might consider just resizing image to a smaller icon value and saving it again
                        PFUser.currentUser()["userIcon"] = newPost.myObj["imageFile"];
                        PFUser.currentUser().saveEventually();
                    }
                    /*var notifObj = PFObject(className:"Notification");
                    //type of notification - in this case, a Image Post (how many #likes i've gotten)
                    notifObj["type"] = NotificationType.IMAGE_POST.rawValue;
                    notifObj["ImagePost"] = newPost.myObj;
                    
                    ServerInteractor.processNotification(sender, targetObject: notifObj);*/
                    //ServerInteractor.saveNotification(PFUser.currentUser(), targetObject: notifObj)
                    
                    var compressRatio = 1.0
                    // create post image file objects in table PostImageFile
                    for image: UIImage in images {
                        let data = UIImageJPEGRepresentation(image, CGFloat(compressRatio));
                        let file = PFFile(name:"posted.jpeg",data:data);
                        
                        var pifObj : PFObject = PFObject(className: "PostImageFile")
                        pifObj["name"] = "posted.jpeg";
                        pifObj["url"] = "";
                        pifObj["data"] = file;
                        pifObj["postId"] = newPost.myObj.objectId;
                        pifObj.saveInBackground()
                    }
                    // create post shop look objects in table PostShopLook
                    for look in looks {
                        var slObj : PFObject = PFObject(className: "PostShopLook")
                        slObj["title"] = look.title;
                        slObj["urlLink"] = look.urlLink;
                        slObj["postId"] = newPost.myObj.objectId;
                        slObj.saveInBackground()
                    }
                    // add post id for potential comments (might created before post stored in parse database due to async way) in the uploaded post
/*                    var query = PFQuery(className:"PostComment")
                    query.whereKey("postAuthorId", equalTo: newPost.myObj["authorId"])
                    query.whereKey("postId", equalTo: "") // empty str as temp post id
                    query.findObjectsInBackgroundWithBlock {
                        (postCmts: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            if let postCmts = postCmts as? [PFObject] {
                                for postCmt in postCmts {
                                    postCmt["postId"] = newPost.myObj.objectId
                                    postCmt.saveInBackground()
                                }
                            }
                        } else {
                            NSLog("Error: \(error.description)")
                        }
                    }
                    // update like as the above comment, empty string as temp liked post id
                    if self.likedBefore("") {
                        self.removeFromLikedPosts("")
                        self.appendToLikedPosts(newPost.myObj.objectId)
                    }
*/
                    finishFunction(imgStruct: newPost)
                }
                else {
                    NSLog("Soem error of some sort");
                    finishFunction(imgStruct: nil)
                }
            });
        }
    }
    
    class func updateProfilePicture(img: UIImage) {
        var compressRatio = 1.0
        let singleData = UIImageJPEGRepresentation(img, CGFloat(compressRatio));
        let singleFile = PFFile(name:"prof.jpeg",data:singleData);
        
        PFUser.currentUser()["userIcon"] = singleFile;
        PFUser.currentUser().saveInBackground();
    }
    
    class func removePost(post: ImagePostStructure) {
        if (PFUser.currentUser().username != post.getAuthor()) {
            //cant delete this post silly!
            return;
        }
        PFUser.currentUser().incrementKey("numPosts", byAmount: -1);
        PFUser.currentUser().saveEventually();
        
        //delete all notifications associated with this notification
        var query = PFQuery(className: "Notification");
        query.whereKey("ImagePost", equalTo: post.myObj);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            if (error != nil) {
                NSLog("Uh oh could not remove imageposts with our ID in them");
                return;
            }
            for object in objects {
                (object as PFObject).deleteInBackground();
            }
        });
        
        
        
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
    
    //when a user likes a post and gives it its first like!
    class func sendFirstLike(newPost: ImagePostStructure) {
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a Image Post (how many #likes i've gotten)
        notifObj["type"] = NotificationType.IMAGE_POST_LIKE.rawValue;
        notifObj["ImagePost"] = newPost.myObj;
        notifObj["message"] = " liked your post!";
        
        ServerInteractor.processNotification(newPost.getAuthorFriend(), targetObject: notifObj);
    }
    class func sendCommentNotif(newPost: ImagePostStructure) {
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a Image Post (how many #likes i've gotten)
        notifObj["type"] = NotificationType.IMAGE_POST_COMMENT.rawValue;
        notifObj["ImagePost"] = newPost.myObj;
        notifObj["message"] = " commented on your post!";
        
        ServerInteractor.processNotification(newPost.getAuthorFriend(), targetObject: notifObj);
    }
    class func updateLikeNotif(newPost: ImagePostStructure) {
        var query = PFQuery(className: "Notification");
        query.whereKey("type", equalTo: NotificationType.IMAGE_POST_LIKE.rawValue);
        query.whereKey("ImagePost", equalTo: newPost.myObj);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("Error updating like notification");
                return;
            }
            if (objects.count > 0) {
                var notifToUpdate = objects[0] as PFObject;
                notifToUpdate["bumpedAt"] = NSDate();
                notifToUpdate["viewed"] = false;
                notifToUpdate["sender"] = PFUser.currentUser().username;
                notifToUpdate["senderId"] = PFUser.currentUser().objectId;
                notifToUpdate.saveEventually();
                ServerInteractor.sendPushNotificationForNotif(InAppNotification(dataObject: notifToUpdate, wasRead: false));
            }
            else {
                ServerInteractor.sendFirstLike(newPost);
            }
        });
    }
    class func updateCommentNotif(newPost: ImagePostStructure) {
        var query = PFQuery(className: "Notification");
        query.whereKey("type", equalTo: NotificationType.IMAGE_POST_COMMENT.rawValue);
        query.whereKey("ImagePost", equalTo: newPost.myObj);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("Error updating like notification");
                return;
            }
            if (objects.count > 0) {
                var notifToUpdate = objects[0] as PFObject;
                notifToUpdate["bumpedAt"] = NSDate();
                notifToUpdate["viewed"] = false;
                notifToUpdate["sender"] = PFUser.currentUser().username;
                notifToUpdate["senderId"] = PFUser.currentUser().objectId;
                notifToUpdate.saveEventually();
                ServerInteractor.sendPushNotificationForNotif(InAppNotification(dataObject: notifToUpdate, wasRead: false));
            }
            else {
                ServerInteractor.sendCommentNotif(newPost);
            }
        });
    }

    class func appendToLikedPosts(id: String) {
        if (PFUser.currentUser()["likedPosts"] == nil) {
            NSLog("Something's wrong bro")
        }
        /*var likedPosts = PFUser.currentUser()["likedPosts"] as Array<String>;
        var likedPostsArray: NSMutableArray = NSMutableArray(array: likedPosts);
        likedPostsArray.insertObject(id, atIndex: 0)
        PFUser.currentUser()["likedPosts"] = likedPostsArray*/
        PFUser.currentUser().addUniqueObject(id, forKey: "likedPosts");
        PFUser.currentUser().saveInBackground()
    }
    class func removeFromLikedPosts(id: String) {
        /*var likedPostsArray = PFUser.currentUser()["likedPosts"] as NSMutableArray
        likedPostsArray.removeObject(id);
        PFUser.currentUser()["likedPosts"] = likedPostsArray*/
        PFUser.currentUser().removeObject(id, forKey: "likedPosts");
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
                NSLog("Error getting my liked posts");
                notifyQueryFinish(0);
            }
        }
    }

    //return ImagePostStructure(image, likes)
    //counter = how many pages I've seen (used for pagination)
    //this method DOES fetch the images along with the data
    //class func getPost(friendsOnly: Bool, finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, sender: HomeFeedController, excludes: Array<ImagePostStructure?>) {
        
    class func getPost(loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)  {
        
        
        //query
        
        var isFirst = (excludes.count == 0);
        
        var query = PFQuery(className:"ImagePost")
        //query.skip = skip * POST_LOAD_COUNT;
        query.limit = POST_LOAD_COUNT;
        query.orderByDescending("createdAt");
        
        var excludeList = convertPostToID(excludes);
        if (!isAnonLogged()) {
            //excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray));
            query.whereKey("authorId", notEqualTo: PFUser.currentUser().objectId);
            query.whereKey("authorId", containedIn: (PFUser.currentUser()["followingIds"] as NSArray));
        }
        /*
        if (friendsOnly && !isAnonLogged()) {
            query.whereKey("author", containedIn: (PFUser.currentUser()["friends"] as NSArray));
            //query.whereKey("objectId", notContainedIn: excludeList);
            //both friends + everyone marked feed from your friends show up here, as long as your friend posted
            //query.whereKey("exclusive", equalTo: PostExclusivity.FRIENDS_ONLY.rawValue); <--- leave this commented
            if (!isAnonLogged()) {
                excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray))
            }
        }
        else {
            //must be an everyone-only post to show in popular feed
            query.whereKey("exclusive", equalTo: PostExclusivity.EVERYONE.rawValue);
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
                if (objects.count == 0 && isFirst) {
                    //I'm probably following 0 people, or the ppl I'm following dont have pictures
                    NSLog("Out of posts to follow")
                    //ServerInteractor.getExplore(loadCount, excludes: [], notifyQueryFinish: notifyQueryFinish, finishFunction: finishFunction);
                    notifyQueryFinish(0);
                    return;
                }
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
                NSLog("Post Error: %@ %@", error, error.userInfo!)
                notifyQueryFinish(0);
            }
        }
    }
    
    
    class func getExplore(loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)  {
        
        var currentDate = NSDate();
        
        //query
        var query = PFQuery(className:"ImagePost")
        //query.skip = skip * POST_LOAD_COUNT;
        
        query.limit = POST_LOAD_COUNT;
        
        query.orderByDescending("likes");
        
        var oneWeekAgo = currentDate.dateByAddingTimeInterval(-14*24*60*60);
        query.whereKey("createdAt", greaterThan: oneWeekAgo);
        //query.orderByDescending("createdAt");
        
        var excludeList = convertPostToID(excludes);
        
        //nothing to exclude: I must be fetching images for first time
        var isFirst: Bool = (excludeList.count == 0);
        
        if (!isAnonLogged()) {
            excludeList.addObjectsFromArray((PFUser.currentUser()["viewHistory"] as NSArray));
            query.whereKey("authorId", notEqualTo: PFUser.currentUser().objectId);
        }
        query.whereKey("objectId", notContainedIn: excludeList);
        //query addAscending/DescendingOrder for extra ordering:
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                // The find succeeded.
                // Do something with the found objects
                
                if (objects.count == 0 && isFirst) {
                    if ((PFUser.currentUser()["viewHistory"] as NSArray).count != 0) {
                        //my search returned 0 results from the start. oh no!
                        NSLog("Out of posts to explore, resetting my viewed post counter")
                        ServerInteractor.resetViewedPosts();
                        ImagePostStructure.unreadAllPosts();
                        ServerInteractor.getExplore(loadCount, excludes: [], notifyQueryFinish: notifyQueryFinish, finishFunction: finishFunction);
                        return;
                    }
                }
                
                var scrambleList = ServerInteractor.scrambler(0, end: objects.count, need: objects.count);
                
                notifyQueryFinish(objects.count);
                
                var post: ImagePostStructure?;
                for (index, object) in enumerate(objects!) {
                    post = ImagePostStructure.dequeueImagePost((object as PFObject));
                    post!.loadImage(finishFunction, index: scrambleList[index]);
                }
            } else {
                // Log details of the failure
                NSLog("Post Error: %@ %@", error, error.userInfo!)
                notifyQueryFinish(0);
            }
        }
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
        query.whereKey("authorId", equalTo: user.getID());
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
                NSLog("Error: %@ %@", error, error.userInfo!)
                notifyQueryFinish(0);
            }
        }
    }
    class func getSubmissionsForSuggest(loadCount: Int, user: FriendEncapsulator, userIndex: Int,  notifyQueryFinish: (Int, Int)->Void, finishFunction: (Int, ImagePostStructure, Int)->Void)  {
        var query = PFQuery(className:"ImagePost")
        query.whereKey("authorId", equalTo: user.userID);
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
                NSLog("Error: %@ %@", error, error.userInfo!)
                notifyQueryFinish(userIndex, 0);
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
                NSLog("Error: %@ %@", error, error.userInfo!)
                notifyQueryFinish(0);
            }
        }
    }

    
    class func readPost(post: ImagePostStructure) {
        var postID = post.myObj.objectId;
        PFUser.currentUser().addUniqueObject(postID, forKey: "viewHistory");
        PFUser.currentUser().saveEventually();
        
    }
    
    //------------------Notification related methods---------------------------------------
    class func processNotification(targetUser: FriendEncapsulator, targetObject: PFObject)->Array<AnyObject?>? {
        return processNotification(targetUser, targetObject: targetObject, controller: nil);
    }
    class func processNotification(targetUser: FriendEncapsulator, targetObject: PFObject, controller: UIViewController?)->Array<AnyObject?>? {
        
        var query: PFQuery = PFUser.query();
        query.whereKey("objectId", equalTo: targetUser.userID);
        var currentUserId: String = "";
        if (ServerInteractor.isAnonLogged()) {
            currentUserId = "Anonymous";
        }
        else {
            currentUserId = PFUser.currentUser().objectId;
        }
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("Querying to add notification failed!");
                return;
            }
            if (objects.count > 0) {
                //i want to request myself as a friend to my friend
                var targetUser = objects[0] as PFUser;
                //targetObject.ACL.setReadAccess(true, forUser: targetUser)
                //targetObject.ACL.setWriteAccess(true, forUser: targetUser)
                
                targetObject.ACL.setPublicReadAccess(true);
                targetObject.ACL.setPublicWriteAccess(true);
                
                targetObject["senderId"] = currentUserId;  //this is necessary for friends!
                targetObject["recipientId"] = targetUser.objectId;
                targetObject["viewed"] = false;
                
                //used by notification object to query order
                targetObject["bumpedAt"] = NSDate();
                
                targetObject.saveInBackground();
                
                //send push notification if applicable
                if (targetUser.objectId == PFUser.currentUser().objectId) {
                    return;
                }
                ServerInteractor.sendPushNotificationForNotif(InAppNotification(dataObject: targetObject, wasRead: false))
            }
            else if (controller != nil) {
                if(objects.count == 0) {
                    //(controller! as FriendTableViewController).notifyFailure("No such user exists!");
                }
                else if (error != nil) {
                    //controller.makeNotificationThatFriendYouWantedDoesntExistAndThatYouAreVeryLonely
                    //(controller! as FriendTableViewController).notifyFailure(error.localizedDescription as String);
                }
            }
        });
        return nil; //useless statement to suppress useless stupid xcode thing
    }
    class func sendPushNotificationForNotif(notif: InAppNotification) {
        //send only to users who have push notifications enabled (default)
        var pushQuery = PFUser.query();
        pushQuery.whereKey("objectId", equalTo: notif.getSender().userID);
        pushQuery.whereKey("receivePush", equalTo: true);
        
        var pushNotif = PFPush();
        pushNotif.setQuery(pushQuery);
        pushNotif.setMessage(notif.getPushMessage());
        pushNotif.sendPushInBackground();
    }
    class func togglePushSettings() {
        var toggled = PFUser.currentUser()["receivePush"] as Bool;
        PFUser.currentUser()["receivePush"] = !(toggled);
        PFUser.currentUser().saveEventually();
    }
    class func isPushEnabled()->Bool {
        var toggled: Bool = true;
        if (PFUser.currentUser()["receivePush"] == nil) {
            PFUser.currentUser()["receivePush"] = toggled;
            PFUser.currentUser().saveEventually();
        }
        else {
            toggled = PFUser.currentUser()["receivePush"] as Bool;
        }
        return toggled;
    }
    
    class func getNumUnreadNotifications(retFunc: (Int)->Void) {
        if (ServerInteractor.isAnonLogged()) {
            retFunc(0);
            return;
        }
        var query = PFQuery(className:"Notification")
        query.whereKey("recipientId", equalTo: PFUser.currentUser().objectId);
        query.whereKey("viewed", equalTo: false);
        query.countObjectsInBackgroundWithBlock({
            (result: Int32, error: NSError!) in
            retFunc(Int(result));
        })
    }
    class func getNotifications(controller: NotifViewController) {
        ServerInteractor.getNotifications(controller, refreshControl: nil);
    }
    class func getNotifications(controller: NotifViewController, refreshControl: UIRefreshControl?) {
        if (isAnonLogged()) {
            if (controller.notifList.count == 0) {
                controller.notifList.append(InAppNotification(message: "To see your notifications sign up and make an account!"));
            }
            return;
        }
        var query = PFQuery(className:"Notification")
        query.whereKey("recipientId", equalTo: PFUser.currentUser().objectId);
        //want most recent first
        //query.orderByDescending("createdAt");
        query.orderByDescending("bumpedAt");
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
                        if (refreshControl != nil) {
                            refreshControl!.endRefreshing()
                        }
                    }
                }
                for index:Int in 0..<objects.count {
                    object = objects![index] as PFObject;
                    var hasBeenViewed = object["viewed"] as Bool;
                    if (index >= NOTIF_COUNT) {
                        if(hasBeenViewed) {
                            object.deleteInBackground();
                            continue;
                        }
                    }
                    if (!hasBeenViewed) {
                        object["viewed"] = true;
                        object.saveEventually();
                    }
                    var item = InAppNotification(dataObject: object, wasRead: hasBeenViewed);
                    if(index >= controller.notifList.count) {
                        //weird issue #7 error happening here, notifList is NOT dealloc'd (exists) WORK
                        //EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
                        controller.notifList.append(item);
                    }
                    else {
                        //controller.notifList[index] = InAppNotification(dataObject: object, message: controller.notifList[index]!.messageString);
                        controller.notifList[index] = item;
                    }
                    controller.notifList[index]!.assignMessage(controller);
                }
                if (refreshControl != nil) {
                    refreshControl!.endRefreshing()
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    //used for default message notifications (i.e. "You have been banned for violating TOS" "Welcome to our app"
    //"Happy April Fool's Day!")
    class func postDefaultNotif(txt: String) {
        //posts a custom notification (like friend invite, etc)
        var notifObj = PFObject(className:"Notification");
        //type of notification - in this case, a default text one
        notifObj["type"] = NotificationType.PLAIN_TEXT.rawValue;
        notifObj["message"] = txt
        //notifObj.saveInBackground()
        
        ServerInteractor.processNotification(FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser()), targetObject: notifObj);
    }
    //you have just requested someone as a friend; this sends the friend you are requesting a notification for friendship
    class func postFollowerNotif(friend: FriendEncapsulator) {
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FOLLOWER_NOTIF.rawValue;
        ServerInteractor.processNotification(friend, targetObject: notifObj);
        
    }
    //you have just accepted your friend's invite; your friend now gets informed that you are now his friend <3
    //note: the func return type is to suppress some stupid thing that happens when u have objc stuff in your swift header
    /*class func postFriendAccept(friendName: String)->Array<AnyObject?>? {
        //first, query + find the user
        var notifObj = PFObject(className:"Notification");
        notifObj["type"] = NotificationType.FRIEND_ACCEPT.rawValue;
        //notifObj.saveInBackground();
        
        ServerInteractor.processNotification(friendName, targetObject: notifObj);
        return nil;
    }*/
    //call this method when either accepting a friend inv or receiving a confirmation notification
    /*class func addAsFriend(friendName: String)->Array<NSObject?>? {
        NSLog("Wrong method being called, please remove!")
        PFUser.currentUser().addUniqueObject(friendName, forKey: "friends");
        PFUser.currentUser().saveEventually();
        return nil;
    }*/

    class func addAsFollower(follower: FriendEncapsulator) {
        if (ServerInteractor.isAnonLogged()) {
            return;
        }
        else if (contains(PFUser.currentUser()["followingIds"] as Array<String>, follower.getID())) {
            return;
        }
        else if (follower.getID() == PFUser.currentUser().objectId) {
            return;
        }
        else {
            ServerInteractor.postFollowerNotif(follower);
            
            var friendObj: PFObject = PFObject(className: "Friendship")
            friendObj.ACL.setPublicReadAccess(true)
            friendObj.ACL.setPublicWriteAccess(true)
            friendObj["followerId"] = PFUser.currentUser().objectId
            friendObj["followingId"] = follower.getID();
            friendObj.saveEventually()
            var followingsArray: NSMutableArray = PFUser.currentUser()["followingIds"] as NSMutableArray;
            followingsArray.insertObject(follower.getID(), atIndex: 0)
            PFUser.currentUser()["followingIds"] = followingsArray
            PFUser.currentUser().saveEventually()
        }
    }
    class func removeAsFollower(follower: FriendEncapsulator) {
        var followingID = follower.getID();
        var followingsArray: NSMutableArray = PFUser.currentUser()["followingIds"] as NSMutableArray
        followingsArray.removeObject(followingID)
        PFUser.currentUser()["followingIds"] = followingsArray
        PFUser.currentUser().saveEventually()
        var query = PFQuery(className: "Friendship");
        query.whereKey("followerId", equalTo: PFUser.currentUser().objectId)
        query.whereKey("followingId", equalTo: followingID)
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
                if (objects.count > 0) {
                    (objects[0] as PFObject).deleteInBackground();
                }
            }
            else {
                NSLog("Failed to remove follower \(followingID)");
            }
        });

    }
    
    class func findFollowers(follower: FriendEncapsulator, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        var followerID = follower.getID();
        var query = PFQuery(className: "Friendship");
        query.whereKey("followingId", equalTo: followerID)
        var followerList: Array<FriendEncapsulator?> = [];
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
                //var followerList: Array<FriendEncapsulator?>  = listToAddTo
                if (error != nil) {
                    NSLog("Could not find my followers");
                    retFunction(retList: []);
                    return;
                }
                for object in objects {
                    var following = object["followerId"] as String
                    var friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(following)
                    followerList.append(friend)
                }
                retFunction(retList: followerList)
            });
    }
    
    class func findFollowing(follower: FriendEncapsulator, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        var followerID = follower.getID()
        var followingList: Array<FriendEncapsulator?> = []
        for objectId in PFUser.currentUser()["followingIds"] as Array<String> {
            var following = FriendEncapsulator.dequeueFriendEncapsulatorWithID(objectId)
            followingList.append(following)
        }
        retFunction(retList: followingList)
        
    }
    
    class func findNumFollowing(follower: FriendEncapsulator, retFunction: (Int)->Void) {
        retFunction(PFUser.currentUser()["followingIds"].count)
    }

    class func findNumFollowers(follower: FriendEncapsulator, retFunction: (Int)->Void) {
        var followerId = follower.getID()
        var query = PFQuery(className: "Friendship");
        query.whereKey("followingId", equalTo: followerId)
        var followerList: Array<FriendEncapsulator?> = [];
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            //var followerList: Array<FriendEncapsulator?>  = listToAddTo
            if (error != nil) {
                NSLog("Could not find numbers of followers");
                retFunction(0);
                return;
            }
            for object in objects {
                var followingId = object["followerId"] as String
                var friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(followingId)
                followerList.append(friend)
            }
            retFunction(followerList.count)
            //return (followerList.count)
        });
        //return followerList.count
    }
    
    //returns if I am already following user X
    class func amFollowingUser(following: FriendEncapsulator, retFunction: (Bool)->Void) {
        if(contains(PFUser.currentUser()["followingIds"] as Array<String>, following.getID())) {
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
    /*class func removeFriend(friendName: String, isHeartBroken: Bool)->Array<NSObject?>? {
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
    }*/
    
    /*
    class func removeFollower(friendName: String, isHeartBroken: Bool)->Array<NSObject?>? {
        NSLog("This looks broken, if you see this code run let me know -Eric")
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
    }*/

    class func getSuggestedFollowers(numToReturn: Int, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        NSLog("Getting from suggested users list first")
        var toRet: Array<FriendEncapsulator?> = [];
        
        var alreadyMyFriends = PFUser.currentUser()["followingIds"] as Array<String>;
        
        var query = PFQuery(className: "SuggestedUsers");
        query.whereKey("userId", notContainedIn: alreadyMyFriends);
        query.whereKey("userId", notEqualTo: PFUser.currentUser().objectId);
        
        //-----add orderby type (rank by popularity?)-------------WORK NEED
        //query......
        //------------------------
        
        
        query.countObjectsInBackgroundWithBlock({(result: Int32, error: NSError!) in
            if (error == nil) {
                if (result == 0) {
                    //retFunction(retList: []);
                    ServerInteractor.getSuggestedFollowersRandom([], numToReturn: numToReturn, retFunction: retFunction);
                }
                else {
                    var nums = 0;
                    var fetchCount = min(numToReturn, Int(result));
                    NSLog("Fetching \(fetchCount), with results \(Int(result))")
                    //getFunction(fetchCount);
                    var scrambleOrder = ServerInteractor.scrambler(0, end: Int(result), need: fetchCount);
                    for i in 0..<fetchCount {
                        var query = PFQuery(className: "SuggestedUsers");
                        query.whereKey("userId", notContainedIn: alreadyMyFriends);
                        query.whereKey("userId", notEqualTo: PFUser.currentUser().objectId);
                        //change random to be hierarched (i.e. biased toward top) as to weigh results toward more popular users
                        //make this unique numbers
                        query.skip = scrambleOrder[i];
                        NSLog("\(query.skip) skip")
                        //WORK NEED
                        query.limit = 1;
                        query.findObjectsInBackgroundWithBlock({
                            (objects: [AnyObject]!, error: NSError!) in
                            NSLog("Query returned")
                            if (error != nil) {
                                NSLog("Couldn't find followers");
                                retFunction(retList: []);
                                return;
                            }
                            if (objects.count == 0) {
                                NSLog("No results?!?");
                            }
                            //for index: Int in 0..<objects.count {
                            var returnedObject = objects[0] as PFObject;
                            toRet.append(FriendEncapsulator.dequeueFriendEncapsulatorWithID(returnedObject["userId"] as String))
                            //}
                            nums += 1;
                            if (nums == fetchCount) {
                                if (fetchCount < numToReturn) {
                                    ServerInteractor.getSuggestedFollowersRandom(toRet, numToReturn: (numToReturn - fetchCount), retFunction: retFunction);
                                }
                                else {
                                    NSLog("Done");
                                    retFunction(retList: toRet);
                                }
                            }
                        })
                    }
                }
            }
            else {
                NSLog("Error querying for suggested followers")
                //getFunction(0);
                retFunction(retList: []);
            }
        });
    }
    
    class func getSuggestedFollowersRandom(toRetPrev: Array<FriendEncapsulator?>, numToReturn: Int, retFunction: (retList: Array<FriendEncapsulator?>)->Void) {
        //screw it I'm going to make it random 3 followers for now
        //let NUM_FOLLOWERS_TO_QUERY: Int32 = 3;
        NSLog("We got \(toRetPrev.count) users from suggested, lets fill rest of gap randomly - \(numToReturn)")
        var toRet: Array<FriendEncapsulator?> = toRetPrev;
        var excludeNamesList: Array<String> = [];
        for i in 0..<toRetPrev.count {
            excludeNamesList.append(toRetPrev[i]!.getID());
        }
        
        var alreadyMyFriends = PFUser.currentUser()["followingIds"] as Array<String>;
        alreadyMyFriends = alreadyMyFriends + excludeNamesList;
        
        var query = PFUser.query();
        query.whereKey("userType", containedIn: RELEVANT_TYPES);
        query.whereKey("numPosts", greaterThanOrEqualTo: 1);
        query.whereKey("objectId", notContainedIn: alreadyMyFriends);
        query.whereKey("objectId", notEqualTo: PFUser.currentUser().objectId);
        
        //-----add orderby type (rank by popularity?)-------------WORK NEED
        //query......
        //------------------------
        
        
        query.countObjectsInBackgroundWithBlock({(result: Int32, error: NSError!) in
            if (error == nil) {
                if (result == 0) {
                    retFunction(retList: []);
                }
                else {
                    var nums = 0;
                    var fetchCount = min(numToReturn, Int(result));
                    NSLog("Fetching \(fetchCount), with results \(Int(result))")
                    //getFunction(fetchCount);
                    var scrambleOrder = ServerInteractor.scrambler(0, end: Int(result), need: fetchCount);
                    for i in 0..<fetchCount {
                        var query = PFUser.query();
                        query.whereKey("userType", containedIn: RELEVANT_TYPES);
                        query.whereKey("numPosts", greaterThanOrEqualTo: 1);
                        query.whereKey("objectId", notContainedIn: alreadyMyFriends);
                        query.whereKey("objectId", notEqualTo: PFUser.currentUser().objectId);
                        //change random to be hierarched (i.e. biased toward top) as to weigh results toward more popular users
                        //make this unique numbers
                        query.skip = scrambleOrder[i];
                        NSLog("\(query.skip) skip")
                        //WORK NEED
                        query.limit = 1;
                        query.findObjectsInBackgroundWithBlock({
                            (objects: [AnyObject]!, error: NSError!) in
                            NSLog("Query returned")
                            if (error != nil) {
                                NSLog("Couldn't find followers");
                                retFunction(retList: []);
                                return;
                            }
                            if (objects.count == 0) {
                                NSLog("No results?!?");
                            }
                            //for index: Int in 0..<objects.count {
                            toRet.append(FriendEncapsulator.dequeueFriendEncapsulator(objects[0] as PFUser));
                            //}
                            nums += 1;
                            if (nums == fetchCount) {
                                NSLog("Done");
                                retFunction(retList: toRet);
                            }
                        })
                    }
                }
            }
            else {
                NSLog("Error querying for suggested followers")
                //getFunction(0);
                retFunction(retList: []);
            }
        });
    }
    
    //not currently used, but might be helpful later on/nice to have a default version
    /*class func getFriends()->Array<FriendEncapsulator?> {
        return getFriends(FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser()));
    }*/
    /*
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
    }*/
    
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
            if (error != nil) {
                NSLog("Error while querying for search terms");
                initFunc(0);
                endFunc();
                return;
            }
            initFunc(objects.count);
            var content: String;
            for index: Int in 0..<objects.count {
                content = (objects[index] as PFObject)["term"] as String;
                receiveFunc(index, content);
            }
            endFunc();
        });
    }
    class func getSearchUsers(term: String, initFunc: (Int)->Void, receiveFunc: (Int, FriendEncapsulator)->Void, endFunc: ()->Void) {
        var twoTermz = term.lowercaseString;
        var query = PFUser.query();
        query.whereKey("username", containsString: twoTermz);
        query.whereKey("userType", containedIn: RELEVANT_TYPES);
        //query.orderByDescending("importance")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!)->Void in
            if (error != nil) {
                NSLog("Error while querying for users")
                initFunc(0);
                endFunc();
                return;
            }
            initFunc(objects.count);
            var content: FriendEncapsulator;
            for index: Int in 0..<objects.count {
                content = FriendEncapsulator.dequeueFriendEncapsulator(objects[index] as PFUser);
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
    class func getSearchContacts(initFunc: (Int)->Void, receiveFunc: (Int, FriendEncapsulator)->Void, endFunc: ()->Void) {
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
    class func getContactNames(initFunc: (Int)->Void, receiveFunc: (Int, FriendEncapsulator)->Void, endFunc: ()->Void) {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        //println("records in the array \(contactList.count)")
        
        var alreadyMyFriends = PFUser.currentUser()["followingIds"] as Array<String>;
        
        var namesList: [String] = [];
        var emailsList: [String] = [];
        
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            
            var fName: AnyObject = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty).takeRetainedValue();
            var firstName: String = "";
            var ffName: AnyObject?;
            ffName = fName;
            if (ffName != nil) {
                firstName = fName as NSString;
            }
            
            var lName: AnyObject = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty).takeRetainedValue();
            var lastName: String = "";
            var llName: AnyObject?;
            llName = lName;
            if (llName != nil) {
                lastName = lName as NSString;   //crashed here again
            }
            
            var cEmails: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty).takeRetainedValue();
            var contactEmail = "";
            for (var ij:CFIndex = 0; ij < ABMultiValueGetCount(cEmails); ij++) {
                var contactEmail = ABMultiValueCopyValueAtIndex(cEmails, ij);
                break;
            }
            
            //kABPersonPhoneProperty, kABPersonEmailProperty
            
            //var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
            //var firstName: String = "";
            //var lastName: String = "";
            //firstName = fName as NSString;
            //lastName = lName as NSString;
            //println ("contactName \(contactName)")
            
            if (firstName != "" || lastName != "") {
                namesList.append(firstName + " " + lastName);
            }
            if (contactEmail != "") {
                emailsList.append(contactEmail);
            }
        }
        var query: PFQuery = PFUser.query();
        query.whereKey("objectId", notContainedIn: alreadyMyFriends);
        query.whereKey("personFullName", containedIn: namesList);
        
        var query2: PFQuery = PFUser.query();
        query2.whereKey("username", notContainedIn: alreadyMyFriends);
        query2.whereKey("email", containedIn: emailsList);
        
        var combinedQuery = PFQuery.orQueryWithSubqueries([query, query2]);
        //combinedQuery.whereKey("username", notContainedIn: alreadyMyFriends);
        combinedQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            if (error != nil) {
                NSLog("Could not find objects");
                initFunc(0);
                endFunc();
                return;
            }
            initFunc(objects.count);
            for index: Int in 0..<objects.count {
                var content = FriendEncapsulator.dequeueFriendEncapsulator(objects[index] as PFUser);
                //var friend = FriendEncapsulator(friendName: content);
                receiveFunc(index, content);
            }
            endFunc();
        });
    }
    class func isLinkedWithFB()->Bool {
        if (PFUser.currentUser()["fbID"] == nil) {
            return false;
        }
        return true;
    }
    
    class func getFBFriendUsers(initFunc: (Int)->Void, receiveFunc: (Int, FriendEncapsulator)->Void, endFunc: ()->Void) {
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
                    friendIds.addObject(friendObject.objectForKey("id")!);
                }
                var alreadyMyFriends = PFUser.currentUser()["followingIds"] as Array<String>;
                var query: PFQuery = PFUser.query();
                query.whereKey("fbID", containedIn: friendIds);
                query.whereKey("objectId", notContainedIn: alreadyMyFriends);
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!) in
                    if (error != nil) {
                        NSLog("Query for facebook users errored");
                        initFunc(0);
                        endFunc();
                        return;
                    }
                    initFunc(objects.count);
                    for index: Int in 0..<objects.count {
                        var content = FriendEncapsulator.dequeueFriendEncapsulator(objects[index] as PFUser);
                        //var friend = FriendEncapsulator(friendName: content);
                        receiveFunc(index, content);
                    }
                    endFunc();
                });
            }
            else {
                NSLog("Error connecting to fb and getting their friends");
                initFunc(0);
                endFunc();
                return;
            }
        });
    }
    
    
    class func wordNumberer(num: Int)->String {
        if (num > 1000000) {
            return "\(num / 1000000)M"
        }
        else if (num > 1000) {
            return "\(num / 1000)K"
        }
        return "\(num)"
    }
    
    class func timeNumberer(fromDate: NSDate)->String {
        var currentDate = NSDate();
        
        var calender = NSCalendar(calendarIdentifier: NSGregorianCalendar)!;
        var components = calender.components(NSCalendarUnit.SecondCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.YearCalendarUnit, fromDate: fromDate, toDate: currentDate, options: NSCalendarOptions.allZeros);
        if (components.year != 0) {
            return "\(components.year)y"
        }
        else if (components.month != 0) {
            return "\(components.month)mo"
        }
        else if (components.day != 0 && components.day >= 7) {
            return "\(components.day / 7)w"
        }
        else if (components.day != 0) {
            return "\(components.day)d"
        }
        else if (components.hour != 0) {
            return "\(components.hour)h"
        }
        else if (components.minute != 0) {
            return "\(components.minute)m"
        }
        else {
            return "\(components.second)s"
        }
    }
    
    //O(N) algorithm in respect to need, regardless of start/end
    //picks N numbers randomly + uniquely from a range start-end
    //used to scramble orders for explore algorithm
    class func scrambler(start:Int, end:Int, need: Int)->Array<Int> {
        if (need > end - start) {
            return [];
        }
        var replacementDict: [Int: Int] = [:];
        var rangeToPick = end - start;
        var picked: Array<Int> = [];
        for i in 0..<need {
            var pick = random() % rangeToPick;
            //if (replacementDict[pick + start] != nil) {
            //replacementDict[pick + start] = replacementDict[pick + start]!;
            //}
            //else {
            if (replacementDict[pick + start] != nil) {
                picked.append(replacementDict[pick+start]!);
            }
            else {
                picked.append(pick+start);
            }
            if (replacementDict[rangeToPick + start - 1] != nil) {
                replacementDict[pick + start] = replacementDict[rangeToPick + start - 1];
            }
            else {
                replacementDict[pick + start] = rangeToPick + start - 1;
            }
            //}
            rangeToPick--;
        }
        return picked;
    }
}
