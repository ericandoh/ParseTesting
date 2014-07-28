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
    init(images: Array<UIImage>, description: String, labels: String) {
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
        
        
        var labelArr = ServerInteractor.separateLabels(labels);
        myObj["labels"] = labelArr;
        
        
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
        myObj.incrementKey("likes")
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
    func loadImage() {
        if (!image) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                //get file objects
                self.image = UIImage(data: result);
            });
        }
    }
    func loadImage(finishFunction: (imgStruct: ImagePostStructure, index: Int)->Void, index: Int) {
        if (!image) {
            var imgFile: PFFile = myObj["imageFile"] as PFFile;
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                if (!error) {
                    //get file objects
                    self.image = UIImage(data: result);
                    finishFunction(imgStruct: self, index: index);
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
    func fetchComments(finishFunction: (input: NSArray)->Void) {
        var commentArray = myObj["comments"] as NSArray;
        finishFunction(input: commentArray);
    }
    func addComment(comment: String) {
        var commentArray = myObj["comments"] as NSMutableArray;
        commentArray.insertObject(PFUser.currentUser().username + ": " + comment, atIndex: 0);
        myObj["comments"] = commentArray;
        myObj.saveInBackground();
    }
}