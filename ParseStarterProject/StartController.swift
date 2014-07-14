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

    /*init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

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
        //NSLog("User should have been fetched with correct properties");
        self.performSegueWithIdentifier("JumpIn", sender: self);
    }
    func stealthUser() {
        NSLog("User may not be synced!");
        self.performSegueWithIdentifier("JumpIn", sender: self);
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
