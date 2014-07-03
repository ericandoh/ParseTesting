//
//  FriendSingleViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/3/14.
//
//

import UIKit

class FriendSingleViewController: UIViewController {

    @IBOutlet var userIcon: UIImageView
    @IBOutlet var friendName: UILabel
    var mainUser: FriendEncapsulator?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (mainUser) {
            friendName.text = mainUser!.getName({self.friendName.text = self.mainUser!.getName({NSLog("Failed twice to fetch name")})});
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //called by a segue while going to a foreign user's page
    func receiveUserInfo(displayFriend: FriendEncapsulator) {
        mainUser = displayFriend;
    }
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func seeFriendsOfFriends(sender: UIButton) {
        NSLog("Not yet implemented")
    }
}
