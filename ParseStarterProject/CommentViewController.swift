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
    @IBOutlet var backImgView: BlurringDarkView!
    @IBOutlet var sendButton: UIButton!

    var commentList: Array<PostComment> = [];
    var likingUsers: Array<FriendEncapsulator> = [];
    
    var postImageList: Dictionary<String, UIImage> = [:];
    
    var currentPost: ImagePostStructure?;
    var backImg: UIImage?;
    
    var navBarView: UIView = UIView(frame: CGRectMake(0, 0, 210, 44))
    var pageOption : Int = 0 // 0 for comment, 1 for likes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        
        var commentButton : UIButton = UIButton(frame: CGRectMake(0, 0, 90, 44))
        commentButton.setTitle("Comments", forState: UIControlState.Normal)
        commentButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal)
        commentButton.titleLabel?.textAlignment = NSTextAlignment.Left
        commentButton.addTarget(self, action: "commentButtonPress:", forControlEvents: UIControlEvents.TouchDown)
        
        var verticalBarLabel: UILabel = UILabel(frame: CGRectMake(90, 0, 25, 44))
        verticalBarLabel.textColor = UIColor.whiteColor()
        verticalBarLabel.text = "|"
        verticalBarLabel.textAlignment = NSTextAlignment.Right
        
        var likeButton : UIButton = UIButton(frame: CGRectMake(115, 0, 100, 44))
        likeButton.setTitle("Likes", forState: UIControlState.Normal)
        likeButton.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal)
        likeButton.titleLabel?.textAlignment = NSTextAlignment.Left
        likeButton.addTarget(self, action: "likeButtonPress:", forControlEvents: UIControlEvents.TouchDown)
        
        navBarView.addSubview(commentButton)
        navBarView.addSubview(verticalBarLabel)
        navBarView.addSubview(likeButton)
        self.navigationItem.titleView = navBarView
        
        // Do any additional setup after loading the view.
        //self.commentTableView.rowHeight = UITableViewAutomaticDimension;
        self.commentTableView.estimatedRowHeight = 50.0;
        //self.navigationTitle.setTitle("Comments", forState: UIControlState.Normal);
        self.commentTextField.backgroundColor = UIColor.clearColor()
        self.commentTextField.borderStyle = UITextBorderStyle.None
        self.commentTextField.layer.borderWidth = 1
        self.commentTextField.layer.borderColor = UIColor.whiteColor().CGColor
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "isTapped:");
        self.commentTableView.addGestureRecognizer(tapRecognizer);
        
        //self.commentTextField.layer.cornerRadius = 5.0
        if (iOS_VERSION > 7.0) {
            self.commentTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    func keyboardWillShow(notif: NSNotification) {
        
        let s: NSValue = notif.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue;
        let rect :CGRect = s.CGRectValue();
        
        commentsTextFieldConstraint.constant = CGFloat(15.0) + rect.height;
        
        self.view.layoutIfNeeded();
        
        var path = NSIndexPath(forRow: self.commentList.count - 1, inSection: 0);
        if (self.commentList.count != 0) {
            self.commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Top, animated: false);
        }

    }
    
    func keyboardWillHide(notif: NSNotification) {
        
        let s: NSValue = notif.userInfo![UIKeyboardFrameBeginUserInfoKey] as NSValue;
        let rect :CGRect = s.CGRectValue();

        commentsTextFieldConstraint.constant = CGFloat(15.0)
        
        self.view.layoutIfNeeded();

    }
    
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        if (currentPost != nil) {
            if pageOption == 0 { // comments page
                getComments()
                showCommentBar()
            } else { // likes page
                getLikedUsers()
                hideCommentBar()
            }
            //backImgView.image = backImg!;
            if backImg! == DEFAULT_USER_ICON {
                backImgView.setImageAndBlur(backImg!);
            } else {
                backImgView.setImageAndBlur(DEFAULT_USER_ICON_BACK);
            }
        }
        self.commentTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        self.sendButton.layer.borderWidth = CGFloat(1.0)
        self.sendButton.layer.borderColor = UIColor.whiteColor().CGColor
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
            self.commentTextField.resignFirstResponder();
        } else {
            self.commentTextField.resignFirstResponder();
            var commentToAdd = commentTextField.text;
            
            if (commentToAdd == "") {
                return;
            }
        
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
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
    }
    
    func commentButtonPress(sender: UIButton!) {
        if pageOption == 1 {
            NSLog("comments")
            pageOption = 0
            flipNavTitleColor()
            getComments()
            showCommentBar()
        }
    }

    func likeButtonPress(sender: UIButton!) {
        if pageOption == 0 {
            NSLog("likes")
            pageOption = 1
            flipNavTitleColor()
            getLikedUsers()
            hideCommentBar()
        }
    }
    
    func flipNavTitleColor() {
        if navBarView.subviews.count > 0 {
            for v in navBarView.subviews as [UIView] {
                if let btn = v as? UIButton {
                    if (btn.titleColorForState(UIControlState.Normal) == SELECTED_COLOR) {
                        btn.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal)
                    } else {
                        btn.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal)
                    }
                }
            }
        }
    }
    
    func getComments() {
        self.commentList = Array<PostComment>();
        currentPost!.fetchComments({(authorInput: NSArray, authorIdInput: NSArray, input: NSArray)->Void in
            for index in 0..<input.count {
                self.commentList.append(PostComment(author: (authorInput[index] as String), authorId: (authorIdInput[index] as String), content: (input[index] as String)));
            }
            self.commentTableView.reloadData();
            var path = NSIndexPath(forRow: self.commentList.count - 1, inSection: 0);
            if (self.commentList.count != 0) {
                self.commentTableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false);
            }
        });
    }
    
    func getLikedUsers() {
        likingUsers = [];
        var likingIds = currentPost!.getLikerIds();
        for likeId in likingIds {
            likingUsers.append(FriendEncapsulator.dequeueFriendEncapsulatorWithID(likeId));
        }
        self.commentTableView.reloadData()
    }
    
    func showCommentBar() { // comment page
        self.commentTextField.enabled = true
        self.commentTextField.hidden = false
        self.sendButton.enabled = true
        self.sendButton.hidden = false
    }
    
    func hideCommentBar() { // like page
        self.commentTextField.enabled = false
        self.commentTextField.hidden = true
        self.sendButton.enabled = false
        self.sendButton.hidden = true
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        if pageOption == 0 {
            return commentList.count;
        } else {
            return likingUsers.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UserTextTableViewCell;
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        // Configure the cell...
        var index: Int = indexPath.row;
        if pageOption == 0 {
            var author = commentList[index].author;
            var authorId = commentList[index].authorId;
            var text = "@" + author + ": " + commentList[index].commentString;
            
            cell.extraConfigurations(FriendEncapsulator.dequeueFriendEncapsulatorWithID(authorId), message: text, enableFriending: false, sender: self);
            cell.descriptionBox.otherAction = {
                () in
                var x = self.commentTextField.resignFirstResponder();
            };
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            
            if cell.respondsToSelector("setSeparatorInset:") {
                cell.separatorInset = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setLayoutMargins:") {
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
            }
        } else {
            var text = likingUsers[index].username;
            cell.extraConfigurations(likingUsers[index], message: text, enableFriending: true, sender: self);
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
        }
        return cell;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int = indexPath.row;
        var recHeight : CGFloat
        if pageOption == 0 {
            var author = commentList[index].author;
            var authorId = commentList[index].authorId;
            var text = "@" + commentList[index].author + ": " + commentList[index].commentString;
            
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(FriendEncapsulator.dequeueFriendEncapsulatorWithID(authorId), message: text, enableFriending: false);
        } else {
            var text = likingUsers[index].username;
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(likingUsers[index], message: text, enableFriending: true);
        }
        
        return recHeight;
    }
    func tableView(tableView: UITableView!, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if pageOption == 0 {
            var index: Int = indexPath.row;
            var author = commentList[index].author;
            var text = "@" + commentList[index].author + ": " + commentList[index].commentString;
            
            var estimatedLines = CGFloat(countElements(text)) / 34.0;
            
            var estimatedWidth = 50.0 + 20.0 * estimatedLines;
            return estimatedWidth
        }
        return CGFloat(50)
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if pageOption == 0 {
            self.commentTextField.resignFirstResponder();
    
        } else {
            if (self.navigationController != nil) {
                var temp = indexPath.row
                var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(likingUsers[temp]);
                self.navigationController!.pushViewController(nextBoard, animated: false);
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
    }
    
    func isTapped(sender: UITapGestureRecognizer) {
        self.commentTextField.resignFirstResponder();
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
                currentPost.addComment((alert.textFields![0] as UITextField).text);
                
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
