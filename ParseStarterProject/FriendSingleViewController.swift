//
//  FriendSingleViewController.swift
//  ParseStarterProject
//
//  Panel for viewing a profile page (not yours)
//
//  Created by Eric Oh on 7/3/14.
//
//

import UIKit
/*
class FriendSingleViewController: UIViewController {

    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var friendName: UILabel!
    var mainUser: FriendEncapsulator?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (mainUser != nil) {
            friendName.text = mainUser!.getName({self.friendName.text = self.mainUser!.getName({NSLog("Failed twice to fetch name")})});
            mainUser!.fetchImage({(image: UIImage)->Void in
                self.userIcon.image = image;
            });
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
    
    @IBAction func seeFriendsOfFriends(sender: UIButton) {
        NSLog("Not yet implemented")
    }
}
*/