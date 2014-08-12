//
//  NewLoginViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/21/14.
//
//

import Foundation

class NewLoginViewController: UIViewController {
    
    
    
    /*init(coder decoder: NSCoder!) {
        super.init(coder: decoder);
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }*/
    
    @IBAction func immediateBrowsing(sender: AnyObject) {
        self.performSegueWithIdentifier("JumpIn", sender: self)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        NSLog("Logging with FB")
        ServerInteractor.loginWithFacebook(self)
        //self.performSegueWithIdentifier("SetUsernameSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController.navigationBar.shadowImage = UIImage();
        self.navigationController.navigationBar.translucent = true;
        self.navigationController.view.backgroundColor = UIColor.clearColor();

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
       // self.performSegueWithIdentifier("SetUsernameSegue", sender: self)
        if (segue!.identifier) {
            if (segue!.identifier == "RegisterSegue") {
                var next: SignUpViewController = segue!.destinationViewController as SignUpViewController
                //next.updateUserFields(self.userTextField.text, withPassword: self.passwordTextField.text)
            }
            /*else if (segue!.identifier == "SetUsername") {
                if (segue!.destinationViewController is FBUsernameSetupViewController) {
                    var nextLol: FBUsernameSetupViewController = segue!.destinationViewController as FBUsernameSetupViewController
                }
            }*/
        }
    }
    func facebookLogin() {
        NSLog("Performing segue");
        self.performSegueWithIdentifier("SetUsername", sender: self)
        NSLog("Done");
    }
    func successfulLogin() {
        self.performSegueWithIdentifier("JumpIn", sender: self)
    }
    func failedLogin(msg: String) {
        let alert: UIAlertController = UIAlertController(title: "Login Failed", message: msg, preferredStyle: UIAlertControllerStyle.Alert);
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //canceled
        }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}