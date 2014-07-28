//
//  ImagePreviewController.swift
//  ParseStarterProject
//
//  Previews the image before user submission, after image selection
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

class ImagePreviewController: UIViewController {

    @IBOutlet var imageView: UIImageView;
    
    @IBOutlet var labelBar: UITextField;
    
    @IBOutlet var textView: UITextView
    
    var receivedImages: Array<UIImage> = [];
    
    var prevLabel: String = "";
    var prevDescrip: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if receivedImages.count > 0 {
            imageView.image = receivedImages[receivedImages.count - 1];
        }
        labelBar.text = prevLabel;
        textView.text = prevDescrip;
    }
    
    //function triggered by pushing check button
    @IBAction func acceptImage(sender: UIButton) {
        //store image and submit (BACKEND)
        /*var choice = exclusiveOptionPanel.selectedSegmentIndex;
        var exclusivity: PostExclusivity = PostExclusivity.EVERYONE;
        switch choice {
            case 1:
                exclusivity = PostExclusivity.FRIENDS_ONLY;
            case 2:
                exclusivity = PostExclusivity.EVERYONE;
            case 3:
                exclusivity = PostExclusivity.MALE_ONLY;
            case 4:
                exclusivity = PostExclusivity.FEMALE_ONLY;
            default:
                exclusivity = PostExclusivity.EVERYONE;
        }*/
        var description = textView.text;
        ServerInteractor.uploadImage(receivedImages, description: description, labels: labelBar!.text);
        
        //reset submission page
        
        
        if (self.navigationController) {
            if (self.navigationController.parentViewController) {
                var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
                overlord.resetWindow(SIDE_MENU_ITEMS[INDEX_OF_UPLOAD]);
                overlord.openHome();
            }
        }
    }
    
    @IBAction func reject(sender: AnyObject) {
        if (self.navigationController) {
            if (self.navigationController.parentViewController) {
                var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
                overlord.resetWindow(SIDE_MENU_ITEMS[INDEX_OF_UPLOAD]);
                overlord.openHome();
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveImage(imageValues: Array<UIImage>, prevLabel: String, prevDescrip: String) {
        receivedImages = imageValues;
        self.prevLabel = prevLabel;
        self.prevDescrip = prevDescrip;
    }

    @IBAction func addMoreImages(sender: UIButton) {
        sendBackImages();
        self.navigationController.popViewControllerAnimated(true);
    }
    func sendBackImages() {
        self.receivedImages = [];
        var currentIndex = self.navigationController.viewControllers.count;
        if (currentIndex >= 2) {
            var prevController: UIViewController = self.navigationController.viewControllers[currentIndex - 2] as UIViewController;
            if (prevController is ImagePickingViewController) {
                (prevController as ImagePickingViewController).receivePreviousImages(labelBar.text, prevDescrip: textView.text);
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        if (self.navigationController.viewControllers.bridgeToObjectiveC().indexOfObject(self) == NSNotFound) {
            sendBackImages();
        }
        super.viewWillDisappear(animated);
    }

    
    
/*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        //-------THIS METHOD DOES NOT RUN--------------
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue!.destinationViewController is ImagePickingViewController) {
            (segue!.destinationViewController as ImagePickingViewController).receivePreviousImages(labelBar.text, prevDescrip: textView.text);
        }
    }
    */

}
