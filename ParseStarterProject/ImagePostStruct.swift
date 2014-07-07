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
    var imageLoaded: Bool = false
    var myObj: PFObject
    init(inputObj: PFObject, shouldLoadImage: Bool) {
        //called when retrieving object (for viewing, etc)
        myObj = inputObj;
        if (shouldLoadImage) {
            //start loading image
            loadImage()
        }
        else {
            imageLoaded = false
        }
    }
    init(image: UIImage, exclusivity: PostExclusivity) {
        //called when making a new post
        //myObj must be saved by caller
        self.image = image;
        let data = UIImagePNGRepresentation(image);
        let file = PFFile(name:"posted.png",data:data);
        //upload - relational data is saved as well
        myObj = PFObject(className:"ImagePost");
        myObj["imageFile"] = file;
        myObj["author"] = PFUser.currentUser().username;
        myObj["likes"] = 0;
        myObj["passes"] = 0;
        myObj["exclusive"] = exclusivity.toRaw();
        myObj["comments"] = [];
        
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
        var imgFile: PFFile = myObj["imageFile"] as PFFile;
        imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
            //get file objects
            self.imageLoaded = true
            self.image = UIImage(data: result);
        });
    }
    func fetchComments(finishFunction: (input: NSArray)->Void) {
        var commentArray = myObj["comments"] as NSArray;
        finishFunction(input: commentArray);
    }
    func addComment(comment: String) {
        var commentArray = myObj["comments"] as NSMutableArray;
        commentArray.insertObject(comment, atIndex: 0);
        myObj["comments"] = commentArray;
        myObj.saveInBackground();
    }
}