//
//  ImagePostStruct.swift
//  ParseStarterProject
//
//  Encapsulating class for an image post, with data about image and link to data object
//
//  Created by Eric Oh on 6/26/14.
//
//


//decided to encapsulate rather than override PFObject so changing code is easier, I can load images semantics, etc.

var imagePostDictionary: [String: ImagePostStructure] = [:];

class ImagePostStructure {
    var image: UIImage?
    var images: Array<UIImage>
    var myObj: PFObject
    var imagesLoaded: Bool = false;
    var isLoadingImages: Bool = false;
    var myLabels : String
    var myDescription: String
    var myShopLooks : Array<ShopLook>
    
    //for search, set this to true to not mark as read any more posts than necessary
    var read: Bool = false;
    
    //var user: PFUser()
    init(inputObj: PFObject) {
        //called when retrieving object (for viewing, etc)
        myObj = inputObj;
        images = [];
        myLabels = ""
        myDescription = ""
        myShopLooks = []
    }
    init(images: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        //called when making a new post
        //myObj must be saved by caller
        var compressRatio = 0.8
        image = images[0];
        let singleData = UIImageJPEGRepresentation(images[0], CGFloat(compressRatio));
        let singleFile = PFFile(name:"posted.jpeg",data:singleData);
        
        self.images = images;
        NSLog("\(self.images.count)");
        self.images.removeAtIndex(0);
        NSLog("\(self.images.count)");
        imagesLoaded = true;
        
        self.myDescription = description
        self.myLabels = labels
        self.myShopLooks = looks
        
        var imgId : Int = 0
        var curScale : Float = 0.9
        var imgArray: Array<PFFile> = [];
        // save individually in table PostImageFile, uncomment when need imageFiles in ImagePost table
/*        for image: UIImage in self.images {
            NSLog("Making PF")
            var data = UIImageJPEGRepresentation(image, CGFloat(compressRatio)); NSLog("image size: \(data.length)")
            while (data.length >= PARSE_PFFILE_LIMIT) {
                data = ImagePostStructure.resizeImage(image, size: CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(CGFloat(curScale), CGFloat(curScale)))) // TODO: specify size, let size = CGSize(width: 20, height: 40)
                curScale -= 0.1
            }
            let file = PFFile(name:"posted.jpeg",data:data);
            imgArray.append(file);
             NSLog("add image: \(imgId) with size: \(data.length) and scale: \(curScale)")
            imgId += 1
        }
*/
        //upload - relational data is saved as well
        myObj = PFObject(className:"ImagePost");
        myObj["imageFile"] = singleFile;     //separating this for sake of faster loading (since most ppl only see first img then move on)
        myObj["imageFiles"] = imgArray; //other images that may be in this file
        NSLog("Size of my image array: \(imgArray)");
        myObj["author"] = PFUser.currentUser().username;
        myObj["authorId"] = PFUser.currentUser().objectId;
        myObj["likes"] = 0;
        myObj["likers"] = [];
        myObj["likerIds"] = [];
        myObj["passes"] = 0;
        NSLog("Deprecated line here, please remove")
        myObj["exclusive"] = PostExclusivity.EVERYONE.rawValue;//exclusivity.rawValue;
        
        myObj["description"] = description;

        myObj["comments"] = [];
        myObj["commentAuthor"] = [];
        myObj["commentAuthorId"] = [];
        
        var descriptionLabels: Array<String> = ServerInteractor.extractStrings(description);
        var labelArr: Array<String> = ServerInteractor.separateLabels(labels, labelsFromDescription: descriptionLabels);
        myObj["labels"] = labelArr;
        
        var looksArray = NSMutableArray();
        for look: ShopLook in looks {
            looksArray.addObject(look.toDictionary());
        }
        myObj["shopLooks"] = looksArray;
        
        
        //setting permissions to public
        //might want to change this for exclusivity posts?
        myObj.ACL.setPublicReadAccess(true);
        myObj.ACL.setPublicWriteAccess(true);
        
        //imagePostDictionary[myObj.objectId] = self;
    }
    class func dequeueImagePost(inputObj: PFObject)->ImagePostStructure {
        var postExist: ImagePostStructure? = imagePostDictionary[inputObj.objectId];
        if (postExist != nil) {
            return postExist!;
        }
        else {
            var newPostToMake = ImagePostStructure(inputObj: inputObj);
            imagePostDictionary[inputObj.objectId] = newPostToMake;
            return newPostToMake;
        }
    }
    class func unreadAllPosts() {
        for (key, post) in imagePostDictionary {
            post.read = false;
        }
    }
    
    class func resizeImage(image:UIImage, size:CGSize) -> NSData {
        var newSize:CGSize = size
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImageJPEGRepresentation(newImage, 0.8)
    }
/*
    class func resizeImage(image:UIImage, size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            var newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData)
            })
        })
    }
*/
    func save() {
        myObj.saveInBackground()
    }
    func like() {
        //increment like counter for this post
        //var likers = PFUser.currentUser()["likers"] as NSMutableArray
        if (myObj["likers"] == nil) {
            myObj["likers"] = [];
            myObj["likerIds"] = [];
        }
        if (isLikedByUser()) {
            myObj.removeObject(ServerInteractor.getUserName(), forKey: "likers");
            myObj.removeObject(ServerInteractor.getUserID(), forKey: "likerIds");
            myObj.incrementKey("likes", byAmount: -1);
            if myObj.objectId != nil {
                ServerInteractor.removeFromLikedPosts(myObj.objectId);
            } else {
                ServerInteractor.removeFromLikedPosts("") // empty string as temp id
            }
        }
        else {
            if (PFUser.currentUser().objectId == getAuthorID()) {
                //do NOT send a notification
            }
            else {
                //bump that old notification back up to the spotlight
                ServerInteractor.updateLikeNotif(self);
            }
            myObj.addUniqueObject(ServerInteractor.getUserName(), forKey: "likers");
            myObj.addUniqueObject(ServerInteractor.getUserID(), forKey: "likerIds")
            myObj.incrementKey("likes")
            
            if myObj.objectId != nil {
                ServerInteractor.appendToLikedPosts(myObj.objectId)
            } else {
                // empty string as id for the just uploaded post in memory, no myObj.objectId yet
                // set actual liked post id in ServerInteractor.uploadImage() later after post created in parse database asynchronously
                ServerInteractor.appendToLikedPosts("")
            }
        }
        myObj.saveInBackground()
    }

    func pass() {
        //increment pass counter for this post
        myObj.incrementKey("passes")
        myObj.saveInBackground()
    }
    func getLikes()->Int {
        return myObj["likes"] as Int
    }
    func getLikerIds()->Array<String> {
        if (myObj.objectId == nil) {
            return []
        }
        
        if (myObj["likers"] == nil) {
            myObj["likers"] = [];
            myObj["likerIds"] = [];
            myObj.saveInBackground();
            return [];
        }
        
        var likerIds : [String] = (myObj["likerIds"]) as Array<String>;
        return likerIds;
    }
    func getPasses()->Int {
        if (myObj.objectId == nil) {
            return 0
        }
        
        return myObj["passes"] as Int
    }
    func getImagesCount()->Int {
        if (myObj.objectId == nil) { NSLog("get images count new uploaded post")
            return self.images.count
        }

        var query = PFQuery(className:"PostImageFile")
        query.whereKey("postId", equalTo:myObj.objectId)
        let count = query.countObjects() - 1 // imgFile(cover) and imgFiles are seperated in original db
        if count >= 0 {
            return count
        } else {
            return 0
        }
    }
    func getCommentsCount()->Int {
        var query = PFQuery(className:"PostComment")
        if (myObj.objectId == nil) {
            query.whereKey("postId", equalTo: "")
        } else {
            query.whereKey("postId", equalTo:myObj.objectId)
        }
        return query.countObjects()
    }
    func getShopLooksCount(finishFunction: (Int?, NSError?)->Void) {
        if (myObj.objectId == nil) {
            finishFunction(self.myShopLooks.count, nil)
            return
        }
        var query = PFQuery(className:"PostShopLook")
        query.whereKey("postId", equalTo:myObj.objectId)
        query.countObjectsInBackgroundWithBlock{(count: Int32, error: NSError!) -> Void in
            if error == nil {
                finishFunction(Int(count), nil)
            } else {
                NSLog("Errror when getting shopLook num: \(error.description)")
                finishFunction(nil, error)
            }
        }
    }
    func getLabels()->String {
        if (myObj.objectId == nil) {
            return self.myLabels
        }
        
        var labelArr = myObj["labels"] as Array<String>;
        var ret = "";
        for label in labelArr {
            ret += "#" + label + " ";
        }
        return ret;
    }
    func isLikedByUser()->Bool {
        if myObj.objectId != nil {
            return ServerInteractor.likedBefore(myObj.objectId);
        } else {
            return ServerInteractor.likedBefore("") // empty str as temp post id
        }
    }
    func isOwnedByMe()->Bool {
        if (myObj.objectId == nil) {
            return true
        }
        
        if (ServerInteractor.isAnonLogged()) {
            return false;
        }
        return (myObj["authorId"] as String) == PFUser.currentUser().objectId;
    }
    func getAgeAsString()->String {
        var date = (myObj.objectId != nil) ? myObj.createdAt : NSDate() ;
        if date != nil {
            return ServerInteractor.timeNumberer(date)
        } else {
            return ServerInteractor.timeNumberer(NSDate())
        }
    }
    func loadImage() {
        NSLog("loadImage() - this function seems unused");
        if (image == nil) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                //get file objects
                self.image = UIImage(data: result);
            });
        }
    }
    func loadImage(finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, index: Int) {
        if (myObj.objectId == nil) {
            finishFunction(imgStruct: self, index: index)
        }
        if (image == nil) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            
            var query = PFQuery(className: "PostImageFile")
            query.whereKey("postId", equalTo: myObj.objectId)
            query.orderByAscending("createdAt")
            query.getFirstObjectInBackgroundWithBlock{(postImageFile: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    let img = postImageFile["data"] as PFFile
                    img.getDataInBackgroundWithBlock({ (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            self.image = UIImage(data: result);
                            finishFunction(imgStruct: self, index: index);
                        }
                        else {
                            NSLog("Error fetching image \(index)");
                        }
                    })
                } else {
                    NSLog("Fail to grab the first post image file")
                    imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            self.image = UIImage(data: result);
                            finishFunction(imgStruct: self, index: index);
                        }
                        else {
                            NSLog("Error fetching image \(index)");
                        }
                    });
                }
            }
        }
        else {
            finishFunction(imgStruct: self, index: index);
        }
    }
    
    //used ONLY by home feed! do NOT use by any other class!
    func loadRestIfNeeded(callBack: (Int)->Void, snapShotViewCounter: Int) {
        NSLog("----------------------Request for more images at \(snapShotViewCounter)-------------------")
        if (imagesLoaded) {
            NSLog("Images are already loaded, calling callback")
            callBack(snapShotViewCounter);
        }
        else if (isLoadingImages) {
            //repetitive call, wait for first call to finish
            //no callback
            NSLog("I already started loading images!")
        }
        else {
            NSLog("Starting load of images")
            isLoadingImages = true;
            
            if (myObj.objectId != nil) {
            var query = PFQuery(className: "PostImageFile")
            query.whereKey("postId", equalTo: myObj.objectId)
            query.orderByAscending("createdAt")
            query.skip = 1
            query.findObjectsInBackgroundWithBlock { (postImgFiles: [AnyObject]!, error: NSError!) in
                if (postImgFiles.count == 0) {
                    NSLog("No results")
                    self.imagesLoaded = true;
                    self.isLoadingImages = false;
                    callBack(snapShotViewCounter);
                    return;
                }
                NSLog("We have \(postImgFiles.count) files to fetch, lets get on it!");
                for (index, postImgFile: PFObject) in enumerate(postImgFiles as [PFObject]!) {
                    var imgFile : PFFile = postImgFile["data"] as PFFile
                    var result = imgFile.getData()
                    var fImage = UIImage(data: result)!;
                    self.images.append(fImage);
                    
                    if (self.images.count == postImgFiles.count) {
                        NSLog("Finished fetching for \(snapShotViewCounter)")
                        self.imagesLoaded = true;
                        self.isLoadingImages = false;
                        callBack(snapShotViewCounter);
                    }
                }
            }
            } else { // current image post is in memory, not in db yet
                self.imagesLoaded = true;
                self.isLoadingImages = false;
                callBack(snapShotViewCounter);
            }
        }
    }
    func isRestLoaded()->Bool {
        return imagesLoaded;
    }
    func isViewingComments(postCounter: Int)->Bool {
        //4 images=>1/5,2/5,3/5,4/5,5/5
        //images.count = 3
        return imagesLoaded && (postCounter >= (images.count + 1));
    }
    
    //this function ASSUMES we have already gone through protocol for loading images!
    func getImageAt(index: Int)->UIImage {
        if (index == 0) {
            return self.image!;
        }
        else {
            if (index - 1 < self.images.count) {
                return self.images[index - 1];
            }
            else {
                NSLog("Whatever called this is inconsistent!");
                return UIImage();
            }
        }
    }
    
    func loadAllImages(finishFunction: (Array<UIImage>)->Void) {
        if (myObj.objectId == nil) {
            loadAllImagesPart3(finishFunction)
        }
        if (image == nil) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            
            var query = PFQuery(className: "PostImageFile")
            query.whereKey("postId", equalTo: myObj.objectId)
            query.orderByAscending("createdAt")
            query.getFirstObjectInBackgroundWithBlock{(postImageFile: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    let img = postImageFile["data"] as PFFile
                    img.getDataInBackgroundWithBlock({ (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            self.image = UIImage(data: result);
                            self.loadAllImagesPart2(finishFunction);
                        }
                        else {
                            NSLog("Error fetching all image");
                        }
                    })
                } else {
                    NSLog("Fail to grab the first post image file")
                    imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            self.image = UIImage(data: result);
                            self.loadAllImagesPart2(finishFunction);
                        }
                        else {
                            NSLog("Error fetching image");
                        }
                    });
                }
            }
        }
        else {
            self.loadAllImagesPart2(finishFunction)
        }
    }
    func loadAllImagesPart2(finishFunction: (Array<UIImage>)->Void) {
        if (imagesLoaded) {
            loadAllImagesPart3(finishFunction);
        }
        else {
            var query = PFQuery(className: "PostImageFile")
            query.whereKey("postId", equalTo: myObj.objectId)
            query.orderByAscending("createdAt")
            query.skip = 1
            query.findObjectsInBackgroundWithBlock { (postImgFiles: [AnyObject]!, error: NSError!) in
                if (postImgFiles.count == 0) {
                    NSLog("No results")
                    self.imagesLoaded = true;
                    self.loadAllImagesPart3(finishFunction);
                    return;                }
//                NSLog("We have \(postImgFiles.count) files to fetch, lets get on it!");
                for (index, postImgFile: PFObject) in enumerate(postImgFiles as [PFObject]!) {
                    var imgFile : PFFile = postImgFile["data"] as PFFile
                    imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            var fImage = UIImage(data: result)!;
                            self.images.append(fImage);
                        }
                        else {
                            NSLog("Error fetching rest of images!")
                        }
                        if (self.images.count == postImgFiles.count) {
                            self.imagesLoaded = true;
                            self.loadAllImagesPart3(finishFunction);
                        }
                    });
                }
            }
        }
    }
    func loadAllImagesPart3(finishFunction: (Array<UIImage>)->Void) {
        var imgArrayToReturn: Array<UIImage> = [];
        imgArrayToReturn.append(self.image!);
        for restImage in self.images {
            imgArrayToReturn.append(restImage);
        }
        finishFunction(imgArrayToReturn);
    }
    
    //deprecated
    //loads all images, as I load I return images by index
    func loadImages(finishFunction: (UIImage?, Bool)->Void, postIndex: Int) {
        NSLog("This method is deprecated: investigate if this nslog shows up")
        //get me img at index 0
        if (postIndex == 0) {
            loadImage({(imgStruct: ImagePostStructure, index: Int)->Void in
                finishFunction(self.image!, false);
            }, index: 0);
        }
        else {
            //get me rest of images
            if (!imagesLoaded) {
                var imgFiles: Array<PFFile> = myObj["imageFiles"] as Array<PFFile>;
                for (index, imgFile: PFFile) in enumerate(imgFiles) {
                    imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                        if (error == nil) {
                            //get file objects
                            var fImage = UIImage(data: result);
                            self.images.append(fImage!);
                            if (index == postIndex - 1) {
                                finishFunction(fImage, false);
                            }
                        }
                        else {
                            NSLog("Failed to fetch images!")
                        }
                        if (index == imgFiles.count - 1) {
                            self.imagesLoaded = true;
                        }
                        });
                }
                if (postIndex - 1 >= imgFiles.count) {
                    finishFunction(nil, true);
                }
                if (imgFiles.count == 0) {
                    imagesLoaded = true;
                }
            }
            else {
                if (postIndex - 1 >= images.count) {
                    finishFunction(nil, true);
                }
                else {
                    finishFunction(images[postIndex - 1], false);
                }
            }
        }
    }
    func fetchComments(finishFunction: (authorInput: NSArray, authorIdInput: NSArray, input: NSArray)->Void) {
        if (myObj.objectId == nil) { NSLog("new post comment 1")
            finishFunction(authorInput: [], authorIdInput: [], input: [])
            return
        }
        //refresh comments by refetching object from server
        var query = PFQuery(className:"PostComment")
        query.whereKey("postId", equalTo:myObj.objectId)
        query.findObjectsInBackgroundWithBlock {
            (comments: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var commentArray : Array<String> = [];
                var commentAuthorArray : Array<String> = [];
                var commentAuthorIdArray : Array<String> = [];
                for comment in comments as Array<PFObject> {
                    commentArray.append(comment["content"] as String);
                    let commentAuthorId = comment["authorId"] as String;
                    let commentAuthor = FriendEncapsulator.dequeueFriendEncapsulatorWithID(commentAuthorId);
                    commentAuthorArray.append(commentAuthor.username)
                    commentAuthorIdArray.append(commentAuthorId)
                }
                finishFunction(authorInput: commentAuthorArray, authorIdInput: commentAuthorIdArray, input: commentArray);
            } else {
                NSLog("Error refetching object for comments");
                finishFunction(authorInput:[], authorIdInput:[], input: []);
            }
        }
    }
    func getAuthorFriend()->FriendEncapsulator {
        var id : String
        if (myObj.objectId == nil) {
            id = PFUser.currentUser().objectId
        } else {
            id = myObj["authorId"] as String
        }
        return FriendEncapsulator.dequeueFriendEncapsulatorWithID(id);
    }
    func getAuthor()->String {
        if (myObj.objectId == nil) {
            return PFUser.currentUser().username
        }
        
        return myObj["author"] as String;
    }
    func getAuthorID()->String {
        if (myObj.objectId == nil) {
            return PFUser.currentUser().objectId
        }
        
        return myObj["authorId"] as String;
    }
    func getDescription()->String {
        if (myObj.objectId == nil) {
            return myDescription
        }
        var mainBody = myObj["description"] as String;
        return mainBody;
    }
    func getDescriptionWithTag()->String {
        if (myObj.objectId == nil) {
            return myDescription + " #" + myLabels
        }
        
        var mainBody = myObj["description"] as String;
        var tags = myObj["labels"] as Array<String>;
        for tag in tags {
            if (mainBody.lowercaseString.rangeOfString("#"+tag) == nil) {
                mainBody = mainBody + " #" + tag;
            }
        }
        return mainBody;
    }
    func getShopLooks()->Array<ShopLook> {
        if (myObj.objectId == nil) {
            return self.myShopLooks
        }
        var retList: Array<ShopLook> = [];
        var query = PFQuery(className:"PostShopLook")
        query.whereKey("postId", equalTo:myObj.objectId)
        query.findObjectsInBackgroundWithBlock {
            (shopLooks: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for shopLook in shopLooks as Array<PFObject> {
                    let sl = ShopLook(title: shopLook["title"] as String, urlLink: shopLook["urlLink"] as String);
                    retList.append(sl);
                }
            } else {
                NSLog("Error refetching object for shopLooks");
            }
        }
        return retList;
    }
    func fetchShopLooks(finishFunction: (input: Array<ShopLook>)->Void) {
        if (myObj.objectId == nil) {
            finishFunction(input: self.myShopLooks)
        } else {
            var retList: Array<ShopLook> = [];
            var query = PFQuery(className:"PostShopLook")
            query.whereKey("postId", equalTo:myObj.objectId)
            query.findObjectsInBackgroundWithBlock {
                (shopLooks: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    for i in 0..<shopLooks.count {
                        let shopLook = shopLooks[i] as PFObject
                        let sl : ShopLook = ShopLook(title: shopLook["title"] as String, urlLink: shopLook["urlLink"] as String);
                        retList.append(sl);
                    }
                } else {
                    NSLog("Error refetching object for shopLooks");
                }
                
                if retList.count == 0 {
                    retList = self.myShopLooks
                }
                finishFunction(input: retList);
            }
        }
    }
    func addComment(comment: String)->PostComment {
        var commentAuthorArray: Array<String> = [];
        var commentArray: Array<String> = [];
        if (myObj["commentAuthor"] != nil) {
            commentAuthorArray = myObj["commentAuthor"] as Array<String>
            commentArray = myObj["comments"] as Array<String>;
        }
        if (PFUser.currentUser().objectId == getAuthorID()) {
            //do NOT send a notification
        }
        else {
            //bump notification
            ServerInteractor.updateCommentNotif(self);
        }
        //else if (commentArray.count == 0) {
        //make a new notification
        //ServerInteractor.sendCommentNotif(self);
        //}
        var author = PFUser.currentUser().username;
        commentAuthorArray.append(author)
        commentArray.append(comment)
        myObj["commentAuthor"] = commentAuthorArray
        myObj["comments"] = commentArray;
        //myObj["commentAuthor"] = commentAuthorArray
        myObj.saveInBackground();
        
        var cmt = PFObject(className: "PostComment");
        cmt["content"] = comment;
        cmt["authorId"] = PFUser.currentUser().objectId;
        cmt["postId"] = myObj.objectId != nil ? myObj.objectId : ""; // if empty like "", set actual post id in ServerInteractor.uploadImage() later after post created in parse database
        cmt["postAuthorId"] = myObj["authorId"];
        cmt.saveInBackground();
        
        return PostComment(author: author, authorId: PFUser.currentUser().objectId, content: comment);
    }
    func updatePost(images: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        //called when making a new post
        //myObj must be saved by caller
        deletePostImageFile()
        var compressRatio = 1.0
 /*
        image = images[0];
        let singleData = UIImageJPEGRepresentation(images[0], CGFloat(compressRatio));
        let singleFile = PFFile(name:"posted.jpeg",data:singleData);
        var pif = PFObject(className: "PostImageFile");
        pif["name"] = "posted.jpeg"
        pif["url"] = ""
        pif["data"] = singleFile
        pif["postId"] = myObj.objectId
        pif.saveInBackground()
        
        self.images = images;
        self.images.removeAtIndex(0);
        imagesLoaded = true;
        
        var imgArray: Array<PFFile> = [];
        for image: UIImage in self.images {
            let data = UIImageJPEGRepresentation(image, CGFloat(compressRatio));
            let file = PFFile(name:"posted.jpeg",data:data);
            imgArray.append(file);
        
            // add image files in PostImageFile
            var pif = PFObject(className: "PostImageFile");
            pif["name"] = "posted.jpeg"
            pif["url"] = ""
            pif["data"] = file
            pif["postId"] = myObj.objectId
            pif.saveInBackground()
        }
        myObj["imageFile"] = singleFile;     //separating this for sake of faster loading (since most ppl only see first img then move on)
        myObj["imageFiles"] = imgArray; //other images that may be in this file
        myObj["description"] = description;
        var descriptionLabels: Array<String> = ServerInteractor.extractStrings(description);
        var labelArr: Array<String> = ServerInteractor.separateLabels(labels, labelsFromDescription: descriptionLabels);
        myObj["labels"] = labelArr;
        myObj["shopLooks"] = looksArray;
        myObj.saveInBackground();
*/
        // create post image file objects in table PostImageFile
        for image: UIImage in images {
            let data = UIImageJPEGRepresentation(image, CGFloat(compressRatio));
            let file = PFFile(name:"posted.jpeg",data:data);
            
            var pifObj : PFObject = PFObject(className: "PostImageFile")
            pifObj["name"] = "posted.jpeg";
            pifObj["url"] = "";
            pifObj["data"] = file;
            pifObj["postId"] = self.myObj.objectId;
            pifObj.saveInBackground()
        }
        
        deletePostShopLook()
        var looksArray = NSMutableArray();
        for look: ShopLook in looks {
            looksArray.addObject(look.toDictionary())
            // add shopLooks in PostShopLooks
            var sl = PFObject(className: "PostShopLook")
            sl["title"] = look.title
            sl["urlLink"] = look.urlLink
            sl["postId"] = myObj.objectId
            sl.saveInBackground()
        }
        
    }
    
    func deletePostImageFile() {
        var query = PFQuery(className: "PostImageFile")
        query.whereKey("postId", equalTo: myObj.objectId)
        query.findObjectsInBackgroundWithBlock{
            (imageFiles: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                PFObject.deleteAllInBackground(imageFiles as [PFObject]!)
            } else {
                NSLog("Error deleting imageFiles for post")
            }
        }
    }
    
    func deletePostShopLook() {
        var query = PFQuery(className:"PostShopLook")
        query.whereKey("postId", equalTo:myObj.objectId)
        query.findObjectsInBackgroundWithBlock {
            (shopLooks: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                PFObject.deleteAllInBackground(shopLooks as [PFObject]!)
            } else {
                NSLog("Error deleting shopLooks for post")
            }
        }
    }
}