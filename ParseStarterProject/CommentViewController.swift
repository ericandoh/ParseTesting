//
//  CommentViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 8/4/14.
//
//

import UIKit

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var commentTableView: UITableView!
    
    @IBOutlet var backImgView: UIImageView!
    var commentList: Array<PostComment> = [];
    
    var postImageList: Dictionary<String, UIImage> = [:];
    
    var currentPost: ImagePostStructure?;
    var backImg: UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.commentTableView.rowHeight = UITableViewAutomaticDimension;
        self.commentTableView.estimatedRowHeight = 60.0;
    }
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        if (currentPost != nil) {
            self.commentList = Array<PostComment>();
            currentPost!.fetchComments({(authorInput: NSArray, input: NSArray)->Void in
                for index in 0..<input.count {
                    self.commentList.append(PostComment(author: (authorInput[index] as String), content: (input[index] as String)));
                }
                self.commentTableView.reloadData();
                });
            backImgView.image = backImg!;
        }
        var path = NSIndexPath(forRow: commentList.count - 1, inSection: 0);
        if (commentList.count != 0) {
            commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: false);
        }
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

    @IBAction func addComment(sender: UIButton) {
        
        var commentToAdd = commentTextField.text;
        
        var comment = currentPost!.addComment(commentToAdd);
        commentList.append(comment);
        self.commentTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: commentList.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic);
        
        commentTextField.text = "";

    }
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        return commentList.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: UserTextTableViewCell = tableView!.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        
        var index: Int = indexPath.row;
        
        var author = commentList[index].author;
        //NSLog("Comment by \(author) saying \(commentList[index].commentString)")
        var text = "@" + commentList[index].author + ": " + commentList[index].commentString;
        
        cell.extraConfigurations(FriendEncapsulator(friendName: author), message: text, enableFriending: false, sender: self);
        /*if (member.type == NotificationType.IMAGE_POST.toRaw()) {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.toRaw()) {
            cell.extraConfigurations(member.getSender(), message: member.messageString, enableFriending: true, sender: self)
        }
        else {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }*/
        
        
        
        
        
        
        
        
        //cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        //cell.textLabel.numberOfLines = 0;
        //cell.textLabel.font = UIFont(name: "Helvetica Neue", size: 17);
        
        
        /*if (postImageList[author] != nil) {
            cell.imageView.image = postImageList[author];
        }
        else {
            cell.imageView.image = LOADING_IMG;
            self.makeTableImage(index);
        }*/
        
            //cell.imageView.image = PFUser.currentUser()["userIcon"] as UIImage
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    /*func makeTableImage(index: Int) {
        var author = commentList[index].author;
        var thisUser = FriendEncapsulator(friendName: author);
        thisUser.fetchImage({(image: UIImage)->Void in
            for path : AnyObject in self.commentTableView.indexPathsForVisibleRows() {
                if ((path as NSIndexPath).row == index) {
                    var cell: UITableViewCell = self.commentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as UITableViewCell;
                    //do stuff with cell
                    cell.imageView.image = image;
                    self.postImageList[author] = image;
                }
            }
            });
    }*/
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        if (index == 0) {
            let alert: UIAlertController = UIAlertController(title: "Write Comment", message: "Your Comment", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler(nil);
            //set alert text field size bigger - this doesn't work, we need a UITextView
            alert.addAction(UIAlertAction(title: "Comment!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                var currentPost: ImagePostStructure = self.imgBuffer!.getImagePostAt(self.viewCounter);
                
                //textFields[0].text
                currentPost.addComment((alert.textFields[0] as UITextField).text);
                
                self.commentList = Array<PostComment>();
                currentPost.fetchComments({(input: NSArray)->Void in
                    for index in 0..<input.count {
                        self.commentList.append(PostComment(content: (input[input.count - (index + 1)] as String)));
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
    }*/
    /*func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)->CGFloat {
        var cellText: NSString?;
        cellText = commentList[indexPath.row].commentString;
        
        var cell: CGRect = tableView.frame;
        
        var textCell = UILabel();
        textCell.text = cellText;
        textCell.numberOfLines = 10;
        var maxSize: CGSize = CGSizeMake(cell.width, 9999);
        var expectedSize: CGSize = textCell.sizeThatFits(maxSize);
        return expectedSize.height + 20;
    }*/

}
