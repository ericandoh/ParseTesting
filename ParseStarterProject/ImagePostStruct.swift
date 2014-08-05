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

class ImagePostStructure
{
    var image: UIImage?
    var images: Array<UIImage>
    var myObj: PFObject
    var imagesLoaded: Bool = false;
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
    func isLikedByUser()->Bool {
        return ServerInteractor.likedBefore(myObj.objectId);
    }
    func loadImage() {
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
                if (!error) {
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
    //loads all images, as I load I return images by index
    func loadImages(finishFunction: (UIImage?, Bool)->Void, postIndex: Int) {
        
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
                        if (!error) {
                            //get file objects
                            var fImage = UIImage(data: result);
                            self.images.append(fImage);
                            if (index == postIndex - 1) {
                                finishFunction(fImage, false);
                            }
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
        var commentAuthorArray = NSArray();
        if (myObj["commentAuthor"]) {
            commentAuthorArray = myObj["commentAuthor"] as NSArray
        }
        var commentArray = myObj["comments"] as NSArray;
        if (commentArray.count > commentAuthorArray.count) {
            var myArray = commentAuthorArray as Array<String>;
            myArray += Array<String>(count: commentArray.count - commentAuthorArray.count, repeatedValue: "");
            commentAuthorArray = myArray as NSArray;
        }
        finishFunction(authorInput: commentAuthorArray, input: commentArray);
    }
    func getAuthor()->String {
        return myObj["author"] as String;
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
        var author = PFUser.currentUser().username;
        commentAuthorArray.insertObject(author, atIndex: commentAuthorArray.count)
        commentArray.insertObject(comment, atIndex: commentArray.count);
        myObj["commentAuthor"] = commentAuthorArray
        myObj["comments"] = commentArray;
        //myObj["commentAuthor"] = commentAuthorArray
        myObj.saveInBackground();
        return PostComment(author: author, content: comment);
    }
}