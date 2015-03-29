//
//  ShopLookViewController.swift
//  FashionStash
//
//  Created by Yao Li on 3/27/15.
//
//

import UIKit

class ShopLookController: UIViewController, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var backImage: UIImageView!
    @IBOutlet var editPostButton: UIButton!
    @IBOutlet var goToWebpageButton: UIButton!
    
    var currentPost : ImagePostStructure?
    var alerter : CompatibleAlertViews?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.blackColor()
    }
    
    @IBAction func backPress(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
    }
    

    @IBAction func editPostAction(sender: AnyObject) {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Edit Post", "Delete Post");
        actionSheet.showInView(UIApplication.sharedApplication().keyWindow)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            NSLog("Cancelled");
        case 1:
            //edit this post, segue to imagepreviewcontroller with right specs
            currentPost!.loadAllImages({(result: Array<UIImage>) in
                var imageEditingControl = self.storyboard!.instantiateViewControllerWithIdentifier("ImagePreview") as ImagePreviewController;
                imageEditingControl.receiveImage(result, post: self.currentPost!)
                self.navigationController!.pushViewController(imageEditingControl, animated: true);
            })
        case 2:
            alerter = CompatibleAlertViews(presenter: self);
            alerter!.makeNoticeWithAction("Confirm Delete", message: "Deleting this post will delete all images in this post's gallery. Are you sure you want to delete this post?", actionName: "Delete", buttonAction: {
                () in
                //delete this post!
                ServerInteractor.removePost(self.currentPost!);
            });
            
        default:
            break;
        }
    }
    
    func receiveFromPrevious(post: ImagePostStructure, backgroundImg: UIImage) {
        self.currentPost = post;
        self.backImage.image = backgroundImg;
    }
}