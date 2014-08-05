//
//  UserTextTableViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/31/14.
//
//

import UIKit

class UserTextTableViewCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!;
    
    @IBOutlet var descriptionBox: LinkFilledTextView!
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var sideConstraint: NSLayoutConstraint!
    
    @IBOutlet var nextAction: UIButton!
    
    var friend: FriendEncapsulator?;
    
    var owner: UIViewController?;

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
            leadingConstraint.constant = 60;
            involvedUser!.fetchImage({(fetchedImage: UIImage)->Void in
                //var newUserIcon: UIImage = ServerInteractor.imageWithImage(fetchedImage, scaledToSize: CGSize(width: 40, height: 40))
                self.userImage!.image = fetchedImage;
                self.userImage!.autoresizingMask = UIViewAutoresizing.None;
                self.userImage!.layer.cornerRadius = (self.userImage!.frame.size.width) / 2
                self.userImage!.layer.masksToBounds = true
                self.userImage!.layer.borderWidth = 0
                //self.userImage!.clipsToBounds = true;
                });
            friend = involvedUser;
        }
        else {
            leadingConstraint.constant = 5;
            //self.userImage!.image = nil;
        }
        if(enableFriending) {
            
            //check if I am already friends with this dude
            
            sideConstraint.constant = 60;
            nextAction.hidden = false;
        }
        else {
            sideConstraint.constant = 5;
            nextAction.hidden = true;
        }
        descriptionBox.owner = sender;
        descriptionBox.setTextAfterAttributing(message);
        descriptionBox.scrollEnabled = false;
        
        
        descriptionBox.sizeToFit();
        NSLog("-->\(descriptionBox.frame.height)")
        var frame = self.contentView.frame;
        
        //var sysSize = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize);
        
        frame.size.height = max(60, descriptionBox.frame.height);
        
        self.backgroundColor = UIColor.clearColor();
        self.contentView.backgroundColor = UIColor.clearColor();
        //self.layoutIfNeeded();
        //self.frame = frame;
        //self.sizeToFit();
    }
    @IBAction func nextActionCalled(sender: UIButton) {
        var username = friend!.username;
        let alert: UIAlertController = UIAlertController(title: "Follow "+username, message: "Follow "+username+"?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler(nil);
        alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            ServerInteractor.postFollowerNotif(username, controller: self.owner!);
            ServerInteractor.addAsFriend(username);
            }));
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.owner!.presentViewController(alert, animated: true, completion: nil)
    }
}
