//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/25/14.
//
//

import Foundation

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var backImage: BlurringDarkView!
    
    @IBAction func changePassword(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "Change your password!",message: "Enter your passwords", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Old password";
        });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "New password";
        });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "New password";
        });
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var oldPass = (alert.textFields[0] as UITextField).text;
            var newPass = (alert.textFields[1] as UITextField).text;
            var newPassConfirm = (alert.textFields[2] as UITextField).text;
            PFUser.logInWithUsernameInBackground(PFUser.currentUser().username, password: oldPass, block: { (user: PFUser!, error: NSError!) in
                if (!error) {
                    if (newPassConfirm == newPass) {
                        PFUser.currentUser().password = newPassConfirm
                        PFUser.currentUser().saveEventually()
                        var alert = UIAlertController(title: "Success!", message: "Your password has been changed!", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                        NSLog("You came too!")
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        var alert = UIAlertController(title: "Oops!", message: "The passwords don't match!", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.passAlert()
                    }
                } else {
                    var alert = UIAlertController(title: "Oops", message: "Your old password is incorrect!", preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                    self.presentViewController(alert, animated: true, completion: nil)
                    }
                });
            }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
        }));
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func passAlert() {
        let alert: UIAlertController = UIAlertController(title: "Change your password!",message: "Enter your passwords", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Old password";
        });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "New password";
        });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Confirm password";
        });
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var oldPass = (alert.textFields[0] as UITextField).text;
            var newPass = (alert.textFields[1] as UITextField).text;
            var newPassConfirm = (alert.textFields[2] as UITextField).text;
            PFUser.logInWithUsernameInBackground(PFUser.currentUser().username, password: oldPass, block: { (user: PFUser!, error: NSError!) in
                if (!error) {
                    if (newPassConfirm == newPass) {
                        PFUser.currentUser().password = newPassConfirm
                        PFUser.currentUser().saveEventually()
                        var alert = UIAlertController(title: "Success!", message: "Your password has been changed!", preferredStyle: UIAlertControllerStyle.Alert);
                        NSLog("You came too!")
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        var alert = UIAlertController(title: "Oops!", message: "The passwords don't match!", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.passAlert()
                    }
                } else {
                    var alert = UIAlertController(title: "Oops", message: "Your old password is incorrect!", preferredStyle: UIAlertControllerStyle.Alert);
                }
            });
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
        }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*@IBAction func reportProblem(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "Report a problem",message: "Enter description of problem", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Report Problem";
        });

    }*/
    
    
    @IBAction func logOffAction(sender: UIButton) {
        if (!ServerInteractor.isAnonLogged()) {
            ServerInteractor.logOutUser();
        }
    }
    
    override func viewDidLoad() {
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController.navigationBar.shadowImage = UIImage();
        self.navigationController.navigationBar.translucent = true;
        self.navigationController.view.backgroundColor = UIColor.clearColor();
        self.navigationController.navigationBar.topItem.title = "Settings";
        self.navigationController.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        var mainUser = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser().username)
        mainUser.fetchImage({(image: UIImage)->Void in
            //self.backImage.image = image;
            self.backImage.setImageAndBlur(image);
        });
    }
    
    func blankAlertWithMessage(title: String, message:String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func connectAccount(sender: UIButton) {
        if (!PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())) {
            PFFacebookUtils.linkUser(PFUser.currentUser(), permissions: FB_PERMISSIONS, block: {
                (succeeded: Bool, error: NSError!) in
                if (succeeded) {
                    self.blankAlertWithMessage("Success", message: "Your account is now linked with facebook");
                }
                else if (error != nil && error.code == 208) {
                    self.blankAlertWithMessage("Failure", message: "This facebook account is already linked to another user!");
                }
                else if (error != nil) {
                    self.blankAlertWithMessage("Failure", message: "Failed to linked this account with facebook - Error \(error.code)");
                }
                else {
                    self.blankAlertWithMessage("Failure", message: "Failed to linked this account with facebook");
                }
            });
        }
        else {
            blankAlertWithMessage("Already linked", message: "This account is already linked with a facebook account");
        }
    }
    
    @IBAction func termsOfService(sender: UIButton) {
        blankAlertWithMessage("Terms of Service", message: "If you are reading this message, this is a failure on part of us. We will add a Terms of Service as soon as possible! Sorry");
    }
    
    @IBAction func aboutFS(sender: UIButton) {
        blankAlertWithMessage("About FashionStash", message: "FashionStash is not just an app, but a place to share with the community the trendy styles and designs of the world. We believe that anybody can become a fashion enthusiast and strive to help you develop your own sense of fashion by delivering to you the very best fashion to your stash!");
    }
    
    
    @IBAction func disableAccount(sender: UIButton) {
        blankAlertWithMessage("In implementation", message: "Sorry, we will implement this feature very soon! Our programmers are working hard to add more features and this should be in the next update");
    }
    
    
    @IBAction func clearHistory(sender: UIButton) {
        var alert = UIAlertController(title: "Clear history?", message: "Clearing history will delete all your likes and your view history. Continue?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Clear History", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var current = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());
            current.friendObj!["likedPosts"] = [];
            current.friendObj!["viewHistory"] = [];
            current.friendObj!.saveEventually();
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
    
}