//
//  StartController.swift
//  ParseStarterProject
//
//  Start screen that immediately segues into the correct screen for the app
//  Either the login screen (if not logged in previously) or the home feed
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

class StartController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(animated: Bool) {
        if (ServerInteractor.isUserLogged()) {
            //user logged in from last session
            ServerInteractor.updateUser(self);
        }
        else {
            self.performSegueWithIdentifier("SignIn", sender: self);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func approveUser() {
        self.performSegueWithIdentifier("JumpIn", sender: self);
    }
    func stealthUser() {
        NSLog("User may not be synced!");
        self.performSegueWithIdentifier("JumpIn", sender: self);
    }

}
