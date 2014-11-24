//
//  LikedUsersViewController.swift
//  FashionStash
//
//  Created by Eric Oh on 8/24/14.
//
//

import UIKit

class LikedUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backImage: BlurringDarkView!
    
    @IBOutlet weak var myTableView: UITableView!
    
    var currentPost: ImagePostStructure?;
    var backImg: UIImage?;
    var likingUsers: Array<FriendEncapsulator> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;

        myTableView.estimatedRowHeight = 50.0;
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        likingUsers = [];
        if (currentPost != nil) {
            var likingNames = currentPost!.getLikers();
            for likeName in likingNames {
                likingUsers.append(FriendEncapsulator.dequeueFriendEncapsulator(likeName));
            }
            myTableView.reloadData();
            backImage.setImageAndBlur(backImg!);
        }
        self.navigationController!.navigationBar.topItem!.title = "Liked By"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveFromPrevious(post: ImagePostStructure, backgroundImg: UIImage) {
        self.currentPost = post;
        //fill up comments list here
        self.backImg = backgroundImg;
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        return likingUsers.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        var index: Int = indexPath.row;
        var text = likingUsers[index].username;
        cell.extraConfigurations(likingUsers[index], message: text, enableFriending: true, sender: self);
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int = indexPath.row;
        
        var text = likingUsers[index].username;
        var recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(likingUsers[index], message: text, enableFriending: true);
        return recHeight;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.navigationController != nil) {
            var temp = indexPath.row
            var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            (nextBoard as UserProfileViewController).receiveUserInfo(likingUsers[temp]);
            self.navigationController!.pushViewController(nextBoard, animated: true);
        }
    }
    
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
