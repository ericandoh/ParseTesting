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
        let myView : UIView = UIView(frame: CGRectMake(0, 0, 300, 30))
        let title : UILabel = UILabel(frame: CGRectMake(60, 0, 300, 20))
        let titleTime : UILabel = UILabel(frame: CGRectMake(60, 20, 50, 10))
        let titlePage : UILabel = UILabel(frame: CGRectMake(110, 20, 15, 10))
        
        title.text = "Wendyslookbook"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont.boldSystemFontOfSize(CGFloat(10.0))
        title.backgroundColor = UIColor.clearColor()

        titleTime.text = "3m ago • "
        titleTime.textColor = UIColor.whiteColor()
        titleTime.font = UIFont.boldSystemFontOfSize(CGFloat(8.0))
        titleTime.backgroundColor = UIColor.clearColor()

        titlePage.text = "2/5"
        titlePage.textColor = UIColor.whiteColor()
        titlePage.font = UIFont.boldSystemFontOfSize(CGFloat(8.0))
        titlePage.backgroundColor = UIColor.clearColor()

        let image : UIImage = UIImage(named: "user.png")!
        let imageView : UIImageView = UIImageView(image: image)
        
        imageView.frame = CGRectMake(20, 0, 30, 30)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        imageView.layer.borderWidth = 0.1
        
        myView.addSubview(title)
        myView.addSubview(titleTime)
        myView.addSubview(titlePage)
        myView.backgroundColor = UIColor.blackColor()
        myView.addSubview(imageView)
        
        self.navigationItem.titleView = myView //imageView;
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
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
