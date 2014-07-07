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
    @IBOutlet var logOffButton: UIButton

    @IBOutlet var userIcon: UIImageView
    var mainUser: FriendEncapsulator = FriendEncapsulator(friend: PFUser.currentUser());
    
    /*init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        if (ServerInteractor.isAnonLogged()) {
            userNameLabel.text = "Not logged in";
            logOffButton.setTitle("Sign In", forState: UIControlState.Normal)
        }
        else {
            // Do any additional setup after loading the view.
            userNameLabel.text = ServerInteractor.getUserName();
            mainUser.fetchImage({(fetchedImage: UIImage)->Void in
                self.userIcon.image = fetchedImage;
            });
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notifyFailure(message: String) {
        
        var alert = UIAlertController(title: "Friend?", message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
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
        if (!ServerInteractor.isAnonLogged()) {
            ServerInteractor.logOutUser();
        }
    }
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Test submission post");
        //lets also try adding to user field
    }
}
