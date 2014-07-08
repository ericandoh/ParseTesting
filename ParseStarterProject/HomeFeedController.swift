//
//  HomeFeedController.swift
//  ParseStarterProject
//
//  Displays images on your home feed with voting options
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

class HomeFeedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var commentView: UIView               //use this for hiding and showing
    @IBOutlet var commentTableView: UITableView     //use this for specific table manipulations
    @IBOutlet var voteCounter: UILabel;
    
    
    var swiperNoSwipe: Bool = false;
    var frontImageView: UIImageView?;
    var backImageView: UIImageView?;
    
    
    //which image we are viewing currently in firstSet
    var viewCounter = 0;
    
    //first set has images to display, viewCounter tells me where in array I am currently viewing
    var firstSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    //second set should be loaded while viewing first set (load in background), switch to this when we run out in firstSet
    var secondSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    
    //which set of images we are on (so we dont have to query all 2 million images at once)
    var numSets = 0;
    
    //an array of comments which will be populated when loading app
    var commentList: Array<PostComment> = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        frontImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        backImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        //var imageHorn: UIImage = UIImage(named: "horned-logo.png");
        
        //replace with methods for fetching first two images
        //(BACKEND)
        frontImageView!.image = UIImage(named: "horned-logo.png");
        backImageView!.image = UIImage(named: "test image 3.jpg");
        self.view.addSubview(frontImageView);
        self.view.addSubview(backImageView);
        
        self.view.bringSubviewToFront(frontImageView);
        //removeme
        firstSet = ServerInteractor.getPost(0);
        
        commentView.hidden = true; //this should be set in storyboard but just in case
    }
    override func viewDidAppear(animated: Bool) {
        //needs work - reload images back into feed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        if (swiperNoSwipe) {
            //in middle of swiping - do nothing
            //later replace this with faster animation
            return;
        }
        
        var location: CGPoint = sender.locationInView(self.view);
        location.x -= 220;
        
        animateImageMotion(location, vote: false);
    }
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        if (swiperNoSwipe) {
            //in middle of swiping - do nothing
            //later replace this with faster animation
            return;
        }
        
        var location: CGPoint = sender.locationInView(self.view);
        location.x += 220;
        
        animateImageMotion(location, vote: true);
    }
    
    func animateImageMotion(towardPoint: CGPoint, vote: Bool) {
        swiperNoSwipe = true;
        if let frontView = frontImageView {
            UIView.animateWithDuration(0.5, animations: {
                frontView.alpha = 0.0;
                frontView.center = towardPoint;
                }
                , completion: { completed in
                    //register vote to backend (BACKEND)
                    //set frontView's image to backView's image
                    if let backView = self.backImageView {
                        frontView.image = backView.image;
                        //reset frontView back to front
                        frontView.frame = CGRect(x: 20, y: 20, width: 280, height: 320);
                        frontView.alpha = 1.0;
                        
                        //fetch new backView image for backView
                        //backView.image = METHOD FOR INSERTING NEW IMAGE HERE (BACKEND)
                        //removeme commented below line
                        //backView.image = UIImage(named: "test image 3.jpg");
                        //removeme
                        if (self.firstSet[self.viewCounter] == nil) {
                            if (self.viewCounter == 0) {
                                //our firstSet is empty - our results have no pictures!
                                //consider resetting numSets back to 0 and repeating our results
                                return;
                            }
                            //reset back to 0, increment set count
                            //numSets++
                            self.viewCounter = 0
                        }
                        else {
                            //register vote back to server
                            if (vote) {
                                //these are causing the object not found for update error
                                self.firstSet[self.viewCounter]!.like();
                                self.voteCounter.textColor = UIColor.greenColor();
                            }
                            else {
                                self.firstSet[self.viewCounter]!.pass();
                                self.voteCounter.textColor = UIColor.redColor();
                            }
                            self.voteCounter!.text = "Last Post: +\(self.firstSet[self.viewCounter]!.getLikes())"
                        }
                        var img : UIImage = (self.firstSet[self.viewCounter])!.image!
                        backView.image = img;
                        self.viewCounter = (self.viewCounter + 1)%(POST_LOAD_COUNT);
                        
                    }
                    self.swiperNoSwipe = false;
                });
        }
    }
    @IBAction func viewComments(sender: UIButton) {
        //initialize tableview with right arguments
        //load latest 20 comments, load more if requested in cellForRowAtIndexPath
        //self.commentTableView.reloadTable()
        if (self.firstSet[self.viewCounter] == nil) {
            //there is no image for this post - no posts on feed
            //no post = no comments
            //this might happen due to network problems
            return;
        }
        //hide the table view that already exists and re-show it once it is loaded with correct comments
        commentView.hidden = false;
        self.view.bringSubviewToFront(commentView);
        
        NSLog("Comments for \(self.viewCounter)")
        self.commentList = Array<PostComment>();
        
        //assume self.viewCounter refers to current post being shown anyways, although right now that is not the case
        //above needs work (bala get on it!)
        var currentPost: ImagePostStructure = self.firstSet[self.viewCounter]!
        
        currentPost.fetchComments({(input: NSArray)->Void in
            for index in 0..input.count {
                self.commentList.append(PostComment(content: (input[index] as String)));
            }
            self.commentTableView.reloadData();
        });
    }
    @IBAction func exitComments(sender: UIButton) {
        commentView.hidden = true;
        //animate this?
    }
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
            //var textView = UITextView(frame: CGRect(x: 12, y: 90, width: 260, height: 50));
            //alert.view.addSubview(textView)
            alert.addTextFieldWithConfigurationHandler(nil);
            //set alert text field size bigger - this doesn't work, we need a UITextView
            /*var frame = (alert.textFields[0] as UITextField).frame;
            frame.size.height = 100;
            (alert.textFields[0] as UITextField).frame = frame;*/
            alert.addAction(UIAlertAction(title: "Comment!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                var currentPost: ImagePostStructure = self.firstSet[self.viewCounter]!;
                
                currentPost.addComment(alert.textFields[0].text);
                
                self.commentList = Array<PostComment>();
                currentPost.fetchComments({(input: NSArray)->Void in
                    for index in 0..input.count {
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
        var labelSize: CGSize = cellText.sizeWithFont(UIFont(name: "Helvetica Neue", size: 17), constrainedToSize: CGSizeMake(280.0, CGFLOAT_MAX), lineBreakMode: NSLineBreakMode.ByWordWrapping)
        return labelSize.height + 20;
    }
}
