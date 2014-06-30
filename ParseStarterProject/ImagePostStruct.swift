//
//  ImagePostStruct.swift
//  ParseStarterProject
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
        //called when retrieving object
        myObj = inputObj;
        if (shouldLoadImage) {
            //start loading image
            loadImage()
        }
        else {
            imageLoaded = false
        }
    }
    init(image: UIImage) {
        //called when making a new post
        //must be saved by caller
        let data = UIImagePNGRepresentation(image);
        let file = PFFile(name:"posted.png",data:data);
        //upload - relational data is saved as well
        myObj = PFObject(className:"ImagePost");
        myObj["imageFile"] = file;
        myObj["author"] = PFUser.currentUser();
        myObj["likes"] = 0;
        myObj["passes"] = 0;
        //add more attributes here
    }
    func save() {
        myObj.saveInBackground()
    }
    func like() {
        //increment like counter for this post
        myObj.incrementKey("likes")
    }
    func pass() {
        //increment pass counter for this post
        myObj.incrementKey("passes")
    }
    func loadImage() {
        var imgFile: PFFile = myObj["imageFile"] as PFFile;
        imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
            //get file objects
            self.imageLoaded = true
            self.image = UIImage(data: imgFile.getData())
        });
    }
}