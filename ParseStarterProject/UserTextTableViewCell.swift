//
//  UserTextTableViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/31/14.
//
//

import UIKit

let EXPANDED_TEXT_CELL_VALUE = CGFloat(55.0);

let CONTRACTED_TEXT_CELL_VALUE = CGFloat(5.0);

class UserTextTableViewCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!;
    
    @IBOutlet var descriptionBox: LinkFilledTextView!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var sideConstraint: NSLayoutConstraint!
    
    @IBOutlet var nextAction: UIButton!
    
    var friend: FriendEncapsulator?;
    
    var owner: UIViewController?;
    
    var friendAction: Bool = false;

    /*override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }*/

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //called by tableview delegate, fills it in with appropriate things
    func extraConfigurations(involvedUser: FriendEncapsulator?, message: String, enableFriending: Bool, sender: UIViewController) {
        //clicking on the image segues to that user's profile page
        //clicking on the message is handled by the linkfilledtextview
        //clicking on the (optional) right button allows you to follow that user
        owner = sender;
        self.userImage!.image = nil;
        if (involvedUser != nil) {
            leadingConstraint.constant = EXPANDED_TEXT_CELL_VALUE;
            if (!PFAnonymousUtils.isLinkedWithUser(involvedUser!.friendObj)) {
                var friendAtTimeOfSnapshot = involvedUser;
                involvedUser!.fetchImage({(fetchedImage: UIImage)->Void in
                    //var newUserIcon: UIImage = ServerInteractor.imageWithImage(fetchedImage, scaledToSize: CGSize(width: 40, height: 40))
                    if (friendAtTimeOfSnapshot!.username == involvedUser!.username) {
                        self.userImage!.image = fetchedImage;
                        //self.userImage!.autoresizingMask = UIViewAutoresizing.None;
                        //self.userImage!.layer.cornerRadius = (self.userImage!.frame.size.width) / 2
                        self.userImage!.layer.cornerRadius = (40.0) / 2
                        //self.userImage!.layer.cornerRadius = (40.0) / 2
                        self.userImage!.layer.masksToBounds = true
                        //self.userImage!.layer.borderWidth = 0
                        //self.userImage!.clipsToBounds = true;
                    }
                });
                friend = involvedUser;
            }
        }
        else {
            leadingConstraint.constant = CONTRACTED_TEXT_CELL_VALUE;
            //self.userImage!.image = nil;
        }
        nextAction.hidden = true;
        //nextAction.setTitle("", forState: UIControlState.Normal);
        if(enableFriending) {
            //self.nextAction.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
            sideConstraint.constant = EXPANDED_TEXT_CELL_VALUE;
            if (involvedUser != nil) {
                ServerInteractor.amFollowingUser(involvedUser!.username, retFunction: {(amFollowing: Bool) in
                    self.friendAction = amFollowing;
                    self.nextAction.hidden = false;
                    if (amFollowing == true) {
                        self.nextAction.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
                    }
                    else if (amFollowing == false) {
                        self.nextAction.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
                    }
                    else {
                        //do nothing, server failed to fetch!
                        NSLog("Failure? \(amFollowing)")
                    }
                });
            }
            //check if I am already friends with this dude
        }
        else {
            sideConstraint.constant = CONTRACTED_TEXT_CELL_VALUE;
            //nextAction.hidden = true;
        }
        descriptionBox.owner = sender;
        if (involvedUser != nil) {
            descriptionBox.setTextAfterAttributing(true, text: message);
        }
        else {
            descriptionBox.setTextAfterAttributing(false, text: message);
        }
        descriptionBox.scrollEnabled = false;
        
        
        //descriptionBox.sizeToFit();
        //var frame = self.contentView.frame;
        
        //var sysSize = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize);
        
        //frame.size.height = max(60, descriptionBox.frame.height);
        
        //var backView: UIView = UIView();
        //backView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor();
        self.contentView.backgroundColor = UIColor.clearColor();
        //self.backgroundView = backView
        //self.layoutIfNeeded();
        //self.frame = frame;
        //self.sizeToFit();
    }
    func setTextFieldLighter() {
        self.descriptionBox.setTextColorBeforeAttributing(UIColor(white: 1.0, alpha: 0.4))
        //self.descriptionBox.textColor = UIColor(white: 1.0, alpha: 0.4);
    }
    func setTextFieldNormal() {
        self.descriptionBox.setTextColorBeforeAttributing(UIColor.whiteColor())
    }
    @IBAction func nextActionCalled(sender: UIButton) {
        var username = friend!.username;
        if (friendAction == false) {
            //follow me
            //ServerInteractor.postFollowerNotif(username, controller: self.owner!);
            ServerInteractor.addAsFollower(username);
            
            //update button
            self.friendAction = true
            self.nextAction.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
        }
        else if (friendAction == true) {
            //unfollow me (if u wish!)
            let alert: UIAlertController = UIAlertController(title: "Unfollow "+username, message: "Unfollow "+username+"?", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                ServerInteractor.removeAsFollower(username);
                //update button
                self.friendAction = false
                self.nextAction.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                //canceled
            }));
            self.owner!.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //no action
        }
        /*
        let alert: UIAlertController = UIAlertController(title: "Follow "+username, message: "Follow "+username+"?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler(nil);
        alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //ServerInteractor.postFollowerNotif(username, controller: self.owner!);
            ServerInteractor.addAsFriend(username);
            }));
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.owner!.presentViewController(alert, animated: true, completion: nil)*/
    }
}
