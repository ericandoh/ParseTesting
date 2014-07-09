//
//  FriendRequestViewController.swift
//  ParseStarterProject
//
//  VC that requests for a friend accept
//
//  Created by Eric Oh on 7/2/14.
//
//

import UIKit

class FriendRequestViewController: UIViewController {

    @IBOutlet var friendNameLabel: UILabel
    
    var notif: InAppNotification?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (notif) {
            friendNameLabel.text = notif!.friendName;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptFriend(sender: UIButton) {
        if (notif) {
            notif!.acceptFriend();
        }
    }

    func receiveNotifObject(notification: InAppNotification) {
        notif = notification;
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
