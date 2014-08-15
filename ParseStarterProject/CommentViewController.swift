//
//  CommentViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 8/4/14.
//
//

import UIKit

let kOFFSET_FOR_KEYBOARD = 80.0

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var commentTableView: UITableView!
    
    @IBOutlet weak var commentsTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet var backImgView: UIImageView!
    var commentList: Array<PostComment> = [];
    
    var postImageList: Dictionary<String, UIImage> = [:];
    
    var currentPost: ImagePostStructure?;
    var backImg: UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.commentTableView.rowHeight = UITableViewAutomaticDimension;
        self.commentTableView.estimatedRowHeight = 50.0;
        //self.navigationTitle.setTitle("Comments", forState: UIControlState.Normal);
        self.commentTextField.backgroundColor = UIColor.clearColor()
        self.commentTextField.borderStyle = UITextBorderStyle.None
        self.commentTextField.layer.borderWidth = 1
        self.commentTextField.layer.borderColor = UIColor.whiteColor().CGColor
        //self.commentTextField.layer.cornerRadius = 5.0
        self.commentTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    func keyboardWillShow(notif: NSNotification) {
        NSLog("Keyboard Will Show")
        
        let s: NSValue = notif.userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue;
        let rect :CGRect = s.CGRectValue();
        
        commentsTextFieldConstraint.constant = CGFloat(15.0) + rect.height;
        
        self.view.layoutIfNeeded();
        
        var path = NSIndexPath(forRow: self.commentList.count - 1, inSection: 0);
        if (self.commentList.count != 0) {
            self.commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: false);
        }

    }
    
    func keyboardWillHide(notif: NSNotification) {
        
        NSLog("Keyboard Will Hide")
        let s: NSValue = notif.userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue;
        let rect :CGRect = s.CGRectValue();

        commentsTextFieldConstraint.constant = CGFloat(15.0)
        
        self.view.layoutIfNeeded();

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
                var path = NSIndexPath(forRow: self.commentList.count - 1, inSection: 0);
                if (self.commentList.count != 0) {
                    self.commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false);
                }
                });
            backImgView.image = backImg!;
        }
        self.navigationController.navigationBar.topItem.title = "Comments"
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
        if (ServerInteractor.isAnonLogged()) {
            var alert = UIAlertController(title: "Error!", message: "Anonymous users can't post comments!", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
        } else {

            var commentToAdd = commentTextField.text;
        
            var comment = currentPost!.addComment(commentToAdd);
            commentList.append(comment);
            self.commentTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: commentList.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic);
        
            commentTextField.text = "";
            
            var path = NSIndexPath(forRow: self.commentList.count - 1, inSection: 0);
            if (self.commentList.count != 0) {
                self.commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: false);
            }
        }
    }
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController.popViewControllerAnimated(true);
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
        var text = "@" + commentList[index].author + ": " + commentList[index].commentString;
        
        cell.extraConfigurations(FriendEncapsulator.dequeueFriendEncapsulator(author), message: text, enableFriending: false, sender: self);
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView!, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index: Int = indexPath.row;
        var author = commentList[index].author;
        var text = "@" + commentList[index].author + ": " + commentList[index].commentString;
        
        var estimatedLines = CGFloat(countElements(text)) / 34.0;
        
        var estimatedWidth = 40.0 + 20.0 * estimatedLines;
        
        return estimatedWidth
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