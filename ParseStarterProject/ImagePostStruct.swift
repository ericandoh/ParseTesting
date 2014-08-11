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
        myObj["likes"] = 0;
        myObj["passes"] = 0;
        NSLog("Deprecated line here, please remove")
        myObj["exclusive"] = PostExclusivity.EVERYONE.toRaw();//exclusivity.toRaw();
        
        myObj["description"] = description;

        myObj["comments"] = [];
        myObj["commentAuthor"] = [];
        
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
    func save() {
        myObj.saveInBackground()
    }
    func like() {
        //increment like counter for this post
        if (isLikedByUser()) {
            //myObj.decrementKey("likes")
            myObj.incrementKey("likes", byAmount: -1);
            ServerInteractor.removeFromLikedPosts(myObj.objectId);
        }
        else {
            if (getLikes() == 0) {
                ServerInteractor.sendFirstLike(self);
            }
            else {
                //bump that old notification back up to the spotlight
                ServerInteractor.updateLikeNotif(self);
            }
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
    func getPasses()->Int {
        return myObj["passes"] as Int
    }
    func getImagesCount()->Int {
        return (myObj["imageFiles"] as Array<PFFile>).count;
    }
    func getCommentsCount()->Int {
        return (myObj["comments"] as Array<String>).count;
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
        return (myObj["author"] as String) == PFUser.currentUser().username;
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
            var imgFiles: Array<PFFile> = myObj["imageFiles"] as Array<PFFile>;
            if (imgFiles.count == 0) {
                NSLog("No results")
                self.imagesLoaded = true;
                isLoadingImages = false;
                callBack(snapShotViewCounter);
                return;
            }
            NSLog("We have \(imgFiles.count) files to fetch, lets get on it!");
            for (index, imgFile: PFFile) in enumerate(imgFiles) {
                imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                    if (error == nil) {
                        //get file objects
                        NSLog("+1");
                        var fImage = UIImage(data: result);
                        self.images.append(fImage);
                    }
                    else {
                        NSLog("Error fetching rest of images!")
                    }
                    if (self.images.count == imgFiles.count) {
                        NSLog("Finished fetching for \(snapShotViewCounter)")
                        self.imagesLoaded = true;
                        self.isLoadingImages = false;
                        callBack(snapShotViewCounter);
                    }
                });
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
            return self.images[index - 1];
        }
    }
    
    func loadAllImages(finishFunction: (Array<UIImage>)->Void) {
        if (image == nil) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                if (error == nil) {
                    //get file objects
                    self.image = UIImage(data: result);
                    self.loadAllImagesPart2(finishFunction)
                }
                else {
                    NSLog("Error fetching image \(index)");
                }
            });
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
            var imgFiles: Array<PFFile> = myObj["imageFiles"] as Array<PFFile>;
            if (imgFiles.count == 0) {
                self.imagesLoaded = true;
                self.loadAllImagesPart3(finishFunction);
                return;
            }
            for (index, imgFile: PFFile) in enumerate(imgFiles) {
                imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                    if (error == nil) {
                        var fImage = UIImage(data: result);
                        self.images.append(fImage);
                    }
                    else {
                        NSLog("Error fetching rest of images!")
                    }
                    if (self.images.count == imgFiles.count) {
                        self.imagesLoaded = true;
                        self.loadAllImagesPart3(finishFunction);
                    }
                });
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
                            self.images.append(fImage);
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
        myObj.fetchInBackgroundWithBlock({
            (object: PFObject!, error: NSError!) in
            if (error == nil) {
                self.myObj = object;
                var commentAuthorArray = NSArray();
                if (self.myObj["commentAuthor"]) {
                    commentAuthorArray = self.myObj["commentAuthor"] as NSArray
                }
                var commentArray = self.myObj["comments"] as NSArray;
                if (commentArray.count > commentAuthorArray.count) {
                    var myArray = commentAuthorArray as Array<String>;
                    myArray += Array<String>(count: commentArray.count - commentAuthorArray.count, repeatedValue: "");
                    commentAuthorArray = myArray as NSArray;
                }
                finishFunction(authorInput: commentAuthorArray, input: commentArray);
            }
            else {
                NSLog("Error refetching object for comments");
                finishFunction(authorInput:[], input: []);
            }
        });
    }
    func getAuthor()->String {
        return myObj["author"] as String;
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
        var lookArray = myObj["shopLooks"] as NSArray;
        var retList: Array<ShopLook> = [];
        for object in lookArray {
            retList.append(ShopLook.fromDictionary(object));
        }
        return retList;
    }
    func fetchShopLooks(finishFunction: (input: Array<ShopLook>)->Void) {
        var lookArray = myObj["shopLooks"] as NSArray;
        var retList: Array<ShopLook> = [];
        for object in lookArray {
            retList.append(ShopLook.fromDictionary(object));
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
        if (commentArray.count == 0) {
            //make a new notification
            ServerInteractor.sendCommentNotif(self);
        }
        else {
            //bump notification
            ServerInteractor.updateCommentNotif(self);
        }
        var author = PFUser.currentUser().username;
        commentAuthorArray.insertObject(author, atIndex: commentAuthorArray.count)
        commentArray.insertObject(comment, atIndex: commentArray.count);
        myObj["commentAuthor"] = commentAuthorArray
        myObj["comments"] = commentArray;
        //myObj["commentAuthor"] = commentAuthorArray
        myObj.saveInBackground();
        
        
        return PostComment(author: author, content: comment);
    }
    func updatePost(images: Array<UIImage>, description: String, labels: String, looks: Array<ShopLook>) {
        //called when making a new post
        //myObj must be saved by caller
        image = images[0];
        let singleData = UIImagePNGRepresentation(images[0]);
        let singleFile = PFFile(name:"posted.png",data:singleData);
        
        self.images = images;
        self.images.removeAtIndex(0);
        imagesLoaded = true;
        
        var imgArray: Array<PFFile> = [];
        for image: UIImage in self.images {
            let data = UIImagePNGRepresentation(image);
            let file = PFFile(name:"posted.png",data:data);
            imgArray.append(file);
        }
        myObj["imageFile"] = singleFile;     //separating this for sake of faster loading (since most ppl only see first img then move on)
        myObj["imageFiles"] = imgArray; //other images that may be in this file
        myObj["description"] = description;
        var descriptionLabels: Array<String> = ServerInteractor.extractStrings(description);
        var labelArr: Array<String> = ServerInteractor.separateLabels(labels, labelsFromDescription: descriptionLabels);
        myObj["labels"] = labelArr;
        
        var looksArray = NSMutableArray();
        for look: ShopLook in looks {
            looksArray.addObject(look.toDictionary());
        }
        myObj["shopLooks"] = looksArray;
        myObj.saveInBackground();
    }
}