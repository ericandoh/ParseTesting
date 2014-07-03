//
//  SingleNotifViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/2/14.
//
//

import UIKit

class SingleNotifViewController: UIViewController {

    @IBOutlet var notifTextLabel: UILabel
    
    var notif: InAppNotification?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if notif {
            notifTextLabel.text = notif!.messageString;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
