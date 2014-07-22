//
//  NewCameraViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/21/14.
//
//

import UIKit



class NewCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //outlets for anon user messages
    @IBOutlet var anonMessage: UILabel!
    
    //outlets for choose gallery button, take picture button, other buttons
    
    var usingCamera: Bool = false;;
    
    var pickedImage: UIImage?;
    
    var currImgs: Array<UIImage> = [];
    
    var startedSegue: Bool = false;
    
    /*init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }*/
    override func viewDidLoad()  {
        super.viewDidLoad();
    }
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        
        if (startedSegue) {
            startedSegue = false;
            return;
        }

        // Do any additional setup after loading the view.
        
        if (ServerInteractor.isAnonLogged()) {
            //disable submissions here
            anonMessage.hidden = false;
            return;
        }
        anonMessage.hidden = true;  //this should be true by default;
        
        //try to use camera immediately
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            var imagePicker :UIImagePickerController = UIImagePickerController(nibName: "UIImagePickerController", bundle: nil);
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.mediaTypes = [kUTTypeImage];
            imagePicker.allowsEditing = false;
            self.presentViewController(imagePicker, animated:false, completion:nil);
            usingCamera = true;
        }
        else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)) {
            var imagePicker: UIImagePickerController = UIImagePickerController();
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            var arr: Array<AnyObject> = [kUTTypeImage];
            imagePicker.mediaTypes = arr;
            imagePicker.allowsEditing = false;
            self.presentViewController(imagePicker, animated:false, completion:nil);
            usingCamera = false;
        }
        else {
            
            let alert: UIAlertController = UIAlertController(title: "No source found", message: "Could not find source of images on this device", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                //canceled
                }));
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivePreviousImages(imgs: Array<UIImage>) {
        startedSegue = false;
        currImgs = imgs;
    }

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.destinationViewController is ImagePreviewController) {
            var nextController = segue.destinationViewController as ImagePreviewController;
            currImgs.append(pickedImage!);
            nextController.receiveImage(currImgs);
        }
        else {
            NSLog("Destination View Controller mismatch???");
            NSLog("Id: %@", segue.identifier);
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        var mediaType: NSString = info[UIImagePickerControllerMediaType] as NSString;
        self.startedSegue = true;
        self.dismissViewControllerAnimated(false, completion: {
            ()->Void in
            if (mediaType == kUTTypeImage.__conversion()) {
                var image: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage;
                //add code here to do something with image I just picked
    
                self.pickedImage = image;
    
                if (self.usingCamera) {
                    UIImageWriteToSavedPhotosAlbum(image,
                    self,
                    "image:finishedSavingWithError:contextInfo:",
                    nil);
                }
                //start segue
                self.performSegueWithIdentifier("ImagePreview", sender:self);
    
    
            }
            else if (mediaType == kUTTypeMovie) {
                // Code here to support video if enabled
            }});
    }
    
    func image(image: UIImage, finishedSavingWithError error: NSError?, contextInfo: ()->Void) {
        if (error) {
            let alert: UIAlertController = UIAlertController(title: "Save failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil);
        self.tabBarController.selectedIndex = 0;
    }

}
