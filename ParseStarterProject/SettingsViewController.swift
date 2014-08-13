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
    
    @IBOutlet weak var backImage: UIImageView!
    
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
    
    @IBAction func reportProblem(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: "Report a problem",message: "Enter description of problem", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Report Problem";
        });

    }
    
    
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
            self.backImage.image = image;
        });
    }
}