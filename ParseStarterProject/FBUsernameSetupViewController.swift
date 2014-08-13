//
//  FBUsernameSetupViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/21/14.
//
//

import Foundation

class FBUsernameSetupViewController: UIViewController {
    
    @IBOutlet weak var fbUsernameTextField: UITextField!
    
    var noRepeat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbUsernameTextField.borderStyle = UITextBorderStyle.None;
        fbUsernameTextField.layer.borderWidth = 1;
        fbUsernameTextField.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUsername() {
        PFUser.currentUser()["username"] = fbUsernameTextField.text
        PFUser.currentUser().saveEventually()
        self.performSegueWithIdentifier("JumpIn", sender: self);
        ServerInteractor.postDefaultNotif("Welcome to InsertAppName! Thank you for signing up for our app!");
    }
    
    @IBAction func submitUsername(sender: AnyObject) {
        if (noRepeat == false)  {
            checkUsernameExists(fbUsernameTextField.text)
        }
    }
    
    func checkUsernameExists(username: String) {
        noRepeat = true
        var query = PFUser.query();
        query.whereKey("username", equalTo: username);
        query.limit = 1;
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil)  {
                if (objects.count != 0) {
                    var alert = UIAlertController(title: "Error!", message: "Username already exists!", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.noRepeat = false
                } else {
                    self.setUsername()
                    self.noRepeat = true
                    
                }
            }
            else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        }

    }
}