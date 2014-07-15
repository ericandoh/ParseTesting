//
//  SingleNotifViewController.swift
//  ParseStarterProject
//
//  Simple VC class to see a single notification individually
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
}
