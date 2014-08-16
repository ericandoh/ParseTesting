//
//  RealLoginViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 8/11/14.
//
//

import UIKit

class RealLoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordTextField.keyboardAppearance = UIKeyboardAppearance.Dark;
        usernameTextField.keyboardAppearance = UIKeyboardAppearance.Dark;

        usernameTextField.borderStyle = UITextBorderStyle.None;
        usernameTextField.layer.borderWidth = 1;
        usernameTextField.layer.borderColor = UIColor.whiteColor().CGColor;
        
        passwordTextField.borderStyle = UITextBorderStyle.None;
        passwordTextField.layer.borderWidth = 1;
        passwordTextField.layer.borderColor = UIColor.whiteColor().CGColor;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPushed(sender: UIButton) {
        var username: String = self.usernameTextField.text
        var password: String = self.passwordTextField.text
        //connect to server + authenticare here (BACKEND)
        ServerInteractor.loginUser(username, password: password, sender: self);
    }

    @IBAction func textFieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    
    @IBAction func forgotPassword(sender: UIButton) {
        let alert: UIAlertController = UIAlertController(title: "Reset password", message: "Enter your email and we'll send you directions on resetting your password!", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler(nil);
        (alert.textFields[0] as UITextField).placeholder = "Your Email"
        alert.addAction(UIAlertAction(title: "Reset P/W", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var email = (alert.textFields[0] as UITextField).text;
            PFUser.requestPasswordResetForEmailInBackground(email, block: {
                (succeeded: Bool, error: NSError!) in
                if (error) {
                    NSLog("Encountered an error sending an email!");
                }
                if (succeeded) {
                    let alert2: UIAlertController = UIAlertController(title: "Reset password", message: "An email will be sent shortly with directions to reset your password", preferredStyle: UIAlertControllerStyle.Alert);
                    alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        //canceled
                    }));
                    self.presentViewController(alert2, animated: true, completion: nil)
                }
                else {
                    let alert3: UIAlertController = UIAlertController(title: "Reset password", message: "Email is invalid; try again", preferredStyle: UIAlertControllerStyle.Alert);
                    alert3.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        //canceled
                    }));
                    self.presentViewController(alert3, animated: true, completion: nil)
                }
            });
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
        }));
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true
    }
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController.popViewControllerAnimated(true);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
