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

class ImagePostStructure
{
    var image: UIImage?
    var images: Array<UIImage>
    var myObj: PFObject
    var imagesLoaded: Bool = false;
    var isLoadingImages: Bool = false;
    
    //for search, set this to true to not mark as read any more posts than necessary
    var read: Bool = false;
    
    //var user: PFUser()
    init(inputObj: PFObject) {
        //called when retrieving object (for viewing, etc)
        myObj = inputObj;
        images = [];
    }
    init(images: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        //called when making a new post
        //myObj must be saved by caller
        image = images[0];
        let singleData = UIImagePNGRepresentation(images[0]);
        let singleFile = PFFile(name:"posted.png",data:singleData);
        
        self.images = images;
        NSLog("\(self.images.count)");
        self.images.removeAtIndex(0);
        NSLog("\(self.images.count)");
        imagesLoaded = true;
        
        var imgArray: Array<PFFile> = [];
        for image: UIImage in self.images {
            NSLog("Making PF")
            let data = UIImagePNGRepresentation(image);
            let file = PFFile(name:"posted.png",data:data);
            imgArray.append(file);
        }
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
            ServerInteractor.removeFromLikedPosts(myObj.objectId);
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
            
            ServerInteractor.appendToLikedPosts(myObj.objectId)
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
    func getLikers()->Array<String> {
        if (myObj["likers"] == nil) {
            myObj["likers"] = [];
            myObj["likerIds"] = [];
            myObj.saveInBackground();
            return [];
        }
        
        var likerIds : [String] = (myObj["likers"]) as Array<String>;
        var likers : [String] = [];
        for likerId in likerIds {
            let friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(likerId);
            likers.append(friend.username);
        }
        return likers;
    }
    func getPasses()->Int {
        return myObj["passes"] as Int
    }
    func getImagesCount()->Int {
        var query = PFQuery(className:"PostImageFile")
        query.whereKey("postId", equalTo:myObj.objectId)
        return (query.countObjects() - 1) // imgFile(cover) and imgFiles are seperated in original db
    }
    func getCommentsCount()->Int {
        var query = PFQuery(className:"PostComment")
        query.whereKey("postId", equalTo:myObj.objectId)
        return query.countObjects()
    }
    func getLabels()->String {
        var labelArr = myObj["labels"] as Array<String>;
        var ret = "";
        for label in labelArr {
            ret += "#" + label + " ";
        }
        return ret;
    }
    func isLikedByUser()->Bool {
        return ServerInteractor.likedBefore(myObj.objectId);
    }
    func isOwnedByMe()->Bool {
        if (ServerInteractor.isAnonLogged()) {
            return false;
        }
        return (myObj["authorId"] as String) == PFUser.currentUser().objectId;
    }
    func getAgeAsString()->String {
        var date = myObj.createdAt;
        return ServerInteractor.timeNumberer(date);
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
    func fetchComments(finishFunction: (authorInput: NSArray, input: NSArray)->Void) {
        //refresh comments by refetching object from server
        var query = PFQuery(className:"PostComment")
        query.whereKey("postId", equalTo:myObj.objectId)
        query.findObjectsInBackgroundWithBlock {
            (comments: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var commentArray : Array<String> = [];
                var commentAuthorArray : Array<String> = [];
                for comment in comments as Array<PFObject> {
                    commentArray.append(comment["content"] as String);
                    let commentAuthorId = comment["authorId"] as String;
                    let commentAuthor = FriendEncapsulator.dequeueFriendEncapsulatorWithID(commentAuthorId);
                    commentAuthorArray.append(commentAuthor.username); NSLog("comment author: %@", commentAuthor.username)
                }
                finishFunction(authorInput: commentAuthorArray, input: commentArray);
            } else {
                NSLog("Error refetching object for comments");
                finishFunction(authorInput:[], input: []);
            }
        }
    }
    func getAuthorFriend()->FriendEncapsulator {
        return FriendEncapsulator.dequeueFriendEncapsulatorWithID(myObj["authorId"] as String);
    }
    func getAuthor()->String {
        return myObj["author"] as String;
    }
    func getAuthorID()->String {
        return myObj["authorId"] as String;
    }
    func getDescription()->String {
        var mainBody = myObj["description"] as String;
        return mainBody;
    }
    func getDescriptionWithTag()->String {
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
                NSLog("Error refetching object for comments");
            }
        }
        return retList;
    }
    func fetchShopLooks(finishFunction: (input: Array<ShopLook>)->Void) {
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
                NSLog("Error refetching object for comments");
            }
        }
        finishFunction(input: retList);
    }
    func addComment(comment: String)->PostComment {
        var commentAuthorArray: NSMutableArray = [];
        var commentArray: NSMutableArray = [];
        if (myObj["commentAuthor"] != nil) {
            commentAuthorArray = myObj["commentAuthor"] as NSMutableArray
            commentArray = myObj["comments"] as NSMutableArray;
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
        commentAuthorArray.insertObject(author, atIndex: commentAuthorArray.count)
        commentArray.insertObject(comment, atIndex: commentArray.count);
        myObj["commentAuthor"] = commentAuthorArray
        myObj["comments"] = commentArray;
        //myObj["commentAuthor"] = commentAuthorArray
        myObj.saveInBackground();
        
        var cmt = PFObject(className: "PostComment");
        cmt["content"] = comment
        cmt["authorId"] = PFUser.currentUser().objectId;
        cmt["postId"] = myObj.objectId;
        cmt["postAuthorId"] = myObj["authorId"];
        cmt.saveInBackground();
        
        return PostComment(author: author, content: comment);
    }
    func updatePost(images: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        //called when making a new post
        //myObj must be saved by caller
        deletePostImageFile()
        image = images[0];
        let singleData = UIImagePNGRepresentation(images[0]);
        let singleFile = PFFile(name:"posted.png",data:singleData);
        var pif = PFObject(className: "PostImageFile");
        pif["name"] = "posted.png"
        pif["url"] = ""
        pif["data"] = singleFile
        pif["postId"] = myObj.objectId
        pif.saveInBackground()
        
        self.images = images;
        self.images.removeAtIndex(0);
        imagesLoaded = true;
        
        var imgArray: Array<PFFile> = [];
        for image: UIImage in self.images {
            let data = UIImagePNGRepresentation(image);
            let file = PFFile(name:"posted.png",data:data);
            imgArray.append(file);
        
            // add image files in PostImageFile
            var pif = PFObject(className: "PostImageFile");
            pif["name"] = "posted.png"
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
        
        deletePostShopLook()
        var looksArray = NSMutableArray();
        for look: ShopLook in looks {
            looksArray.addObject(look.toDictionary())
            // add shopLooks in PostShopLooks
            var sl = PFObject(className: "PostShopLook")
            sl["tile"] = look.title
            sl["urlLink"] = look.urlLink
            sl["postId"] = myObj.objectId
            sl.saveInBackground()
        }
        myObj["shopLooks"] = looksArray;
        myObj.saveInBackground();
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