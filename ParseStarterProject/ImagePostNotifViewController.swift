//
//  ImagePostNotifViewController.swift
//  ParseStarterProject
//
//  Panel to show an image associated with a notification
//
//  Created by Eric Oh on 7/2/14.
//
//

import UIKit

class ImagePostNotifViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var commentView: UIView
    @IBOutlet var postTitle: UILabel
    @IBOutlet var imageView: UIImageView
    @IBOutlet var commentTableView: UITableView

    var notif: InAppNotification?;
    var imgPost: ImagePostStructure?;
    
    var commentList: Array<PostComment> = [];

    @IBAction func comments(sender: AnyObject) {
        commentView.hidden = false;
        if (notif) {
            notif!.getComments({(commentary: Array<String>) -> Void in
                for comment in commentary {
                    NSLog(comment);
                }
                for comment in commentary {
                    var com: PostComment = PostComment(content: comment)
                    self.commentList.append(com)
                }
                self.commentTableView.reloadData();
                });
        }
    }
    
    override func viewDidLoad() {
        //second
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        if (imgPost) {
            imgPost!.loadImage({
                (imgStruct: ImagePostStructure, index: Int)->Void in
                self.imageView.image = imgStruct.image;
                }, index: 0);
            postTitle.text = "Your post! (tbfilled)";
        }
        else if (notif) {
            notif!.getImagePost().fetchIfNeededInBackgroundWithBlock({
                (object:PFObject!, error: NSError!)->Void in
                self.imgPost = ImagePostStructure(inputObj: object);
                
                self.imgPost!.loadImage({
                    (imgStruct: ImagePostStructure, index: Int)->Void in
                    self.imageView.image = imgStruct.image;
                    }, index: 0);
                
            });
            
            //for now, set post title to notification title?
            postTitle.text = notif!.messageString;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    func receiveNotifObject(notification: InAppNotification) {
        //first, notif controller calls this first
        notif = notification;
    }
    func receiveImagePost(post: ImagePostStructure) {
        imgPost = post;
    }
    
    @IBAction func Exit(sender: UIButton) {
        commentView.hidden = true;
        //animate this?
    }
    
    //--------------------TableView delegate methods-------------------------
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        return commentList.count + 1;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UITableViewCell
        
        var index: Int = indexPath.row;
        
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = UIFont(name: "Helvetica Neue", size: 17);
        
        if (index == 0) {
            cell.textLabel.text = "Add Comment";
        }
        else {
            cell.textLabel.text = commentList[index - 1].commentString;
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        if (index == 0) {
            let alert: UIAlertController = UIAlertController(title: "Write Comment", message: "Your Comment", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler(nil);
            //set alert text field size bigger - this doesn't work, we need a UITextView
            alert.addAction(UIAlertAction(title: "Comment!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                var obj = self.notif!.getImagePost()
                
                var currentPost: ImagePostStructure = ImagePostStructure(inputObj: obj)
                
                currentPost.addComment((alert.textFields[0] as UITextField).text);
                
                self.commentList = Array<PostComment>();
                currentPost.fetchComments({(input: NSArray)->Void in
                    for index in 0..<input.count {
                        self.commentList.append(PostComment(content: (input[index] as String)));
                    }
                    self.commentTableView.reloadData();
                    });
                }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                //canceled
                }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //clicked on other comment - if implement comment upvoting, do it here
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)->CGFloat {
        var cellText: NSString;
        if (indexPath.row == 0) {
            cellText = "Add Comment";
        }
        else {
            cellText = commentList[indexPath.row - 1].commentString;
        }
        
        var cell: CGRect = tableView.frame;
        
        var textCell = UILabel();
        textCell.text = cellText;
        textCell.numberOfLines = 10;
        var maxSize: CGSize = CGSizeMake(cell.width, 9999);
        var expectedSize: CGSize = textCell.sizeThatFits(maxSize);
        return expectedSize.height + 20;
    }


}
