//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/25/14.
//
//

import Foundation

import UIKit

//let SETTINGS_TABLEVIEW_HEADER_HEIGHT = CGFloat(40);

//let SETTINGS_TABLE_INSET = CGFloat(10);

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backImage: BlurringDarkView!
    
    var alerter:CompatibleAlertViews?;

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
    
    
    //---------------tableview methods----------------
    /*func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return SETTINGS_OPTIONS.count;
    }*/
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return SETTINGS_OPTIONS.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as UITableViewCell;
        
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel.numberOfLines = 0;

        var optionName = SETTINGS_OPTIONS[indexPath.row];
        if (contains(SETTINGS_HEADER_NAMES, optionName)) {
            cell.textLabel.font = UIFont(name: "HelveticaNeueLTPro-Th", size: 18);
        }
        else {
            cell.textLabel.font = UIFont(name: "HelveticaNeueLTPro-Th", size: 12);
        }
        cell.textLabel.text = optionName;
        cell.textLabel.textColor = UIColor.whiteColor();

        return cell;
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //do nothing for now....
        
    }
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index: Int = indexPath.row;
        var optionName = SETTINGS_OPTIONS[indexPath.row];
        if (contains(SETTINGS_HEADER_NAMES, optionName)) {
            return 40;
        }
        else {
            return 30;
        }
    }
    /*
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, SETTINGS_TABLEVIEW_HEADER_HEIGHT));
        var label = UILabel(frame: CGRectMake(SETTINGS_TABLE_INSET, 0, tableView.frame.size.width - 2 * SETTINGS_TABLE_INSET, SETTINGS_TABLEVIEW_HEADER_HEIGHT));
        label.font = UIFont(name: "HelveticaNeueLTPro-Lt", size: 18);
        label.text = SETTINGS_HEADER_NAMES[section];
        label.backgroundColor = UIColor.clearColor();
        label.textColor = UIColor.whiteColor();

        var topLine = UIImageView(frame: CGRectMake(SETTINGS_TABLE_INSET, 0, tableView.frame.size.width - 2 * SETTINGS_TABLE_INSET, 1));
        topLine.backgroundColor = UIColor.whiteColor();
        var bottomLine = UIImageView(frame: CGRectMake(SETTINGS_TABLE_INSET, SETTINGS_TABLEVIEW_HEADER_HEIGHT - 1, tableView.frame.size.width - 2 * SETTINGS_TABLE_INSET, 1));
        bottomLine.backgroundColor = UIColor.whiteColor();

        var backTransparentView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width, SETTINGS_TABLEVIEW_HEADER_HEIGHT));
        backTransparentView.image = DEFAULT_BUTTON_SOLID_BACKGROUND;
        backTransparentView.alpha = 0.9;

        view.addSubview(backTransparentView);
        view.addSubview(label);
        //view.addSubview(topLine);
        //view.addSubview(bottomLine);
        view.backgroundColor = UIColor.clearColor();
        return view;
    }*/
    /*
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int)->CGFloat
    {
        return SETTINGS_TABLEVIEW_HEADER_HEIGHT;
    }*/
    
    //---------------end tableview methods----------------
    
    @IBAction func changePassword(sender: AnyObject) {
        self.passAlert();
    }
    
    func passAlert() {
        
        alerter = CompatibleAlertViews(presenter: self);
        alerter!.makeNoticeWithActionAndFieldAndField("Change your password", message: "Enter passwords", actionName: "Submit", actionHolder1: "Old password", actionHolder2: "New password", actionString1: "", actionString2: "", secure1: true, secure2: true, buttonAction: {
            (field1: String, field2: String) in
            var oldPass = field1;
            var newPass = field2;
            PFUser.logInWithUsernameInBackground(PFUser.currentUser().username, password: oldPass, block: { (user: PFUser!, error: NSError!) in
                if (error == nil) {
                    self.alerter!.makeNoticeWithActionAndField("Verify password", message: "Enter your new password again to verify", actionName: "Submit", actionHolder: "New password", secure: true, buttonAction: {(field: String) in
                        if (field == field2) {
                            PFUser.currentUser().password = newPass
                            PFUser.currentUser().saveEventually()
                            CompatibleAlertViews.makeNotice("Success!", message: "Your password has been changed!", presenter: self);
                            /*var alert = UIAlertController(title: "Success!", message: "Your password has been changed!", preferredStyle: UIAlertControllerStyle.Alert);
                            self.presentViewController(alert, animated: true, completion: nil)*/
                        }
                        else {
                            CompatibleAlertViews.makeNotice("Oops!", message: "The passwords don't match!", presenter: self);
                            /*var alert = UIAlertController(title: "Oops!", message: "The passwords don't match!", preferredStyle: UIAlertControllerStyle.Alert);
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                            self.presentViewController(alert, animated: true, completion: nil)*/
                            self.passAlert()
                        }
                    });
                } else {
                    CompatibleAlertViews.makeNotice("Oops!", message: "Your old password is incorrect!", presenter: self);
                    //var alert = UIAlertController(title: "Oops", message: "Your old password is incorrect!", preferredStyle: UIAlertControllerStyle.Alert);
                }
            });
        })

        /*
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
                if (error == nil) {
                    if (newPassConfirm == newPass) {
                        PFUser.currentUser().password = newPassConfirm
                        PFUser.currentUser().saveEventually()
                        CompatibleAlertViews.makeNotice("Success!", message: "Your password has been changed!", presenter: self);
                        /*var alert = UIAlertController(title: "Success!", message: "Your password has been changed!", preferredStyle: UIAlertControllerStyle.Alert);
                        self.presentViewController(alert, animated: true, completion: nil)*/
                    } else {
                        CompatibleAlertViews.makeNotice("Oops!", message: "The passwords don't match!", presenter: self);
                        /*var alert = UIAlertController(title: "Oops!", message: "The passwords don't match!", preferredStyle: UIAlertControllerStyle.Alert);
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
                        self.presentViewController(alert, animated: true, completion: nil)*/
                        self.passAlert()
                    }
                } else {
                    CompatibleAlertViews.makeNotice("Oops!", message: "Your old password is incorrect!", presenter: self);
                    //var alert = UIAlertController(title: "Oops", message: "Your old password is incorrect!", preferredStyle: UIAlertControllerStyle.Alert);
                }
            });
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
        }));
        self.presentViewController(alert, animated: true, completion: nil)*/
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
    
    func blankAlertWithMessage(title: String, message:String) {
        CompatibleAlertViews.makeNotice(title, message: message, presenter: self);
        /*
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)*/
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
        alerter = CompatibleAlertViews(presenter: self);
        alerter!.makeNoticeWithAction("Clear history?", message: "Clearing history will delete all your likes and your view history. Continue?", actionName: "Clear History", buttonAction: {
            () in
            var current = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());
            current.friendObj!["likedPosts"] = [];
            current.friendObj!["viewHistory"] = [];
            current.friendObj!.saveEventually();
        });
        /*
        var alert = UIAlertController(title: "Clear history?", message: "Clearing history will delete all your likes and your view history. Continue?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Clear History", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var current = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());
            current.friendObj!["likedPosts"] = [];
            current.friendObj!["viewHistory"] = [];
            current.friendObj!.saveEventually();
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)*/
    }
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
    
}