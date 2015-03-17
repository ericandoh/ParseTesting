//
//  PhotoDisplayViewController.swift
//  FashionStash
//
//  Created by Yao Li on 3/13/15.
//
//

import Foundation
import UIKit

class PhotoDisplayViewController: UIViewController, UIActionSheetDelegate, CTAssetsPickerControllerDelegate {
    
    var photos : Array<ALAsset> = []
    var popover : UIPopoverController!
    
    @IBOutlet var contentArea: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let image : UIImage = UIImage(named: "Icon29@2x.png")!
        let imageView : UIImageView = UIImageView(image: image)
        self.navigationItem.titleView = imageView;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPhotoOptions(sender: AnyObject) {
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending: // iOS >= 8.0
            println("iOS >= 8.0")
            
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
            
            // 2
            let deleteAction = UIAlertAction(title: "Camera", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Take photo with camera")
            })
            let saveAction = UIAlertAction(title: "Saved Photos", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Pick from saved photos")
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Cancelled")
            })
            
            
            // 4
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)
            
            // 5
            self.presentViewController(optionMenu, animated: true, completion: nil)
        case .OrderedAscending: // iOS < 8.0
            println("iOS < 8.0")
            
            let actionSheet = UIActionSheet(title: "ActionSheet", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera", "Saved Photos")
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
            case 0:
                NSLog("Cancel");
                break;
            case 1:
                NSLog("Camera");
                break;
            case 2:
                NSLog("Photo Library");
                break;
            default:
                NSLog("Default");
                break;
                //Some code here..
        }
        
    }
    
    @IBAction func tapHeart(sender: AnyObject) {
        loadPhotos()
    }
    func loadPhotos() {
        var picker : CTAssetsPickerController = CTAssetsPickerController()
        picker.assetsFilter = ALAssetsFilter.allPhotos()
        picker.showsCancelButton = (UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad)
        picker.delegate = self
        picker.selectedAssets = NSMutableArray(array: self.photos as NSArray)
        self.presentViewController(picker, animated: true, completion: nil)
        
        let content = self.storyboard!.instantiateViewControllerWithIdentifier("Test") as UIViewController;
//        self.addChildViewController(content);
//        self.contentArea.addSubview(content.view);    //new
//        self.setContentConstraints(content);
//        //self.view.addSubview(content.view);
//        content.didMoveToParentViewController(self);
//        UIView.animateWithDuration(0.3, animations: {()->Void in
//            content.view.alpha = 1;
//        });
        if (content is UINavigationController) { NSLog("move in")
            (content as UINavigationController).popToRootViewControllerAnimated(false)
        }
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        if (self.popover != nil) {
            self.popover.dismissPopoverAnimated(true)
        } else {
            picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.photos = assets as [ALAsset]!
    }
    
    func setContentConstraints(controller: UIViewController) {
        var myConstraints = controller.view.constraints();
        controller.view.removeConstraints(myConstraints);
        var topConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0);
        var leadingConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0);
        var trailingConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0);
        var bottomConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0);
        self.contentArea.addConstraint(topConstraint);
        self.contentArea.addConstraint(leadingConstraint);
        self.contentArea.addConstraint(trailingConstraint);
        self.contentArea.addConstraint(bottomConstraint);
        controller.view.addConstraints(myConstraints);
    }
}
