//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var userNameLabel: UILabel
    @IBOutlet var friendAddField: UITextField

    /*init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userNameLabel.text = ServerInteractor.getUserName();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notifyFailure(message: String) {
        let viewDialogue = UIAlertView(title: "Could not find friend", message: message, delegate: nil, cancelButtonTitle: "Cancel");
        viewDialogue.show();
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logOff(sender: UIButton) {
        ServerInteractor.logOutUser();
    }
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Lets post something for goodness sake!");
        //lets also try adding to user field
        //PFUser.currentUser()["reallyrandom"]=5;
        //PFUser.currentUser().setValue(5, forKey: "letstrythisinstead");
        //PFUser.currentUser().setObject("for goodness sake", forKey: "holyshitdoesanythingwork")
    }
    @IBAction func addFriendTrigger(sender: UIButton) {
        //add friend named friendAddField
        NSLog("Adding friend \(friendAddField.text)")
        ServerInteractor.postFriendRequest(friendAddField.text, controller: self);
    }
}
