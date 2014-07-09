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
    
    let loadingImg: UIImage = UIImage(named: "horned-logo.png");
    let endingImg: UIImage = UIImage(named: "daniel-craig.jpg");
    
    var swiperNoSwipe: Bool = false;
    var frontImageView: UIImageView?;
    var backImageView: UIImageView?;
    
    
    //which image we are viewing currently in firstSet
    var viewCounter = 0;
    
    //first set has images to display, viewCounter tells me where in array I am currently viewing
    var firstSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    //second set should be loaded while viewing first set (load in background), switch to this when we run out in firstSet
    var secondSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    
    //tells me how much of my set is loaded
    var loadedSet: Array<Bool> = Array<Bool>();
    //tells me which set is loading (first or second) - this should be most of the time the 2nd set
    var loadedSetNum: Int = 1;
    //tells me how many posts I have loaded so far (so I know if I have loaded all my posts)
    var loadedCount: Int = 0;
    
    //if my current image is at the end image
    var atEnd: Bool = false;
   
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
        //image loading screen -> horned-logo
        
        self.view.addSubview(frontImageView);
        self.view.addSubview(backImageView);
        
        self.view.bringSubviewToFront(frontImageView);
        //removeme
        
        
        commentView.hidden = true; //this should be set in storyboard but just in case
    }
    override func viewDidAppear(animated: Bool) {
        //needs work - reload images back into feed
        NSLog("initial view has appeared");
        resetToStart();
    }
    func resetToStart() {
        NSLog("resetting to start");
        frontImageView!.image = loadingImg;
        backImageView!.image = loadingImg;
        
        viewCounter = 0;    //we are at start of image sequence
        loadedSetNum = 1;   //load into first set
        loadedCount = 0;    //have 0 images loaded
        atEnd = false;
        //loadedSet = Array<Bool>(count: POST_LOAD_COUNT, repeatedValue: false);
        ServerInteractor.getPost(getReturnList, sender: self);
    }
    func setPostArraySize(size: Int) {
        //called by server to set size of array of images we are fetching, before retrieving
        NSLog("Fetched size of my next set: \(size)")
        NSLog("For set \(loadedSetNum)")
        if (size == 0) {
            //we fetched an array of size 0...
            if (loadedSetNum == 1) {
                //this is our first set, and we have no images to display
                NSLog("VC should be 0: \(viewCounter)")
                frontImageView!.image = endingImg;
                backImageView!.image = endingImg;
                atEnd = true;
            }
            else {
                //do nothing, just make sure to set backImg to endingImg when firstSet ends
            }
        }
        loadedCount = 0;
        if (loadedSetNum == 1) {
            firstSet = Array<ImagePostStructure?>(count: size, repeatedValue: nil);
        }
        else {
            secondSet = Array<ImagePostStructure?>(count: size, repeatedValue: nil);
        }
        
        loadedSet = Array<Bool>(count: size, repeatedValue: false); //none of values loaded yet
    }
    
    func getReturnList(imgStruct: ImagePostStructure, index: Int){
        NSLog("Fetching img post at \(index) for list# \(loadedSetNum)")
        if (loadedSetNum == 1) {
            firstSet[index] = imgStruct;
            loadedSet[index] = true;
            if (index == viewCounter) {
                //my first image needs to be loaded ASAP, it is first image that needs to be shown
                NSLog("Setting front img")
                frontImageView!.image = firstSet[viewCounter]!.image;   //this changes it from the loading scene
            }
            else if (index == viewCounter + 1) {
                //my back image needs to be loaded
                NSLog("Setting back image")
                backImageView!.image = firstSet[viewCounter + 1]!.image;
            }
            loadedCount++;
            if (loadedCount == firstSet.count) {
                //finished loading all of first set, and there is more to load...?
                NSLog("First set is done loading, let's now load the 2nd set");
                loadedSetNum = 2;
                ServerInteractor.getPost(getReturnList, sender: self);
            }
        }
        else {
            secondSet[index] = imgStruct;
            loadedSet[index] = true;
            //no need to check if I need this image right now; first set is the one buffering
            if (index == 0 && viewCounter == firstSet.count - 1) {
                //my VC is at the last img in firstSet; and backImg is not loaded
                NSLog("Setting first image of my backimg")
                backImageView!.image = secondSet[0]!.image;
            }
            loadedCount++;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        
        var location: CGPoint = sender.locationInView(self.view);
        location.x -= 220;
        
        animateImageMotion(location, vote: false);
    }
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        
        var location: CGPoint = sender.locationInView(self.view);
        location.x += 220;
        
        animateImageMotion(location, vote: true);
    }
    
    func animateImageMotion(towardPoint: CGPoint, vote: Bool) {
        if (swiperNoSwipe) {
            //in middle of swiping - do nothing
            //later replace this with faster animation
            return;
        }
        if (loadedSet.count > 0 && !loadedSet[viewCounter]) {
            //we are waiting for frontImg to load; should (not?) swipe over a loading screen
            //but can swipe if nothing is in queue to refresh
            NSLog("Cannot swipe while first image is not loaded");
            return;
        }
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
                        NSLog("Swipe \(self.viewCounter)")
                        
                        
                        if (!(self.atEnd)) {
                            if (vote) {
                                //these are causing the object not found for update error
                                self.firstSet[self.viewCounter]!.like();
                                self.voteCounter.textColor = UIColor.greenColor();
                            }
                            else {
                                self.firstSet[self.viewCounter]!.pass();
                                self.voteCounter.textColor = UIColor.redColor();
                            }
                            //mark post as read
                            self.voteCounter!.text = "Last Post: +\(self.firstSet[self.viewCounter]!.getLikes())"
                            
                            self.viewCounter += 1
                            
                            if (self.viewCounter == self.firstSet.count) {
                                //we have reached end of our array
                                self.viewCounter = 0;
                            }
                            
                            if (self.loadedSetNum == 1) {
                                if (self.viewCounter == self.firstSet.count - 1) {
                                    //need to load 2nd set images, but first set isn't done loading!!!
                                    //this is impossible, since we just showed all of first set though!
                                    NSLog("OP is a phony");
                                }
                                else if (self.loadedSet[self.viewCounter+1]) {
                                    NSLog("image is loaded, setting")
                                    self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image;
                                }
                                else {
                                    NSLog("image is not loaded!")
                                    self.backImageView!.image = self.loadingImg;
                                }
                            }
                            else {
                                if (self.viewCounter == self.firstSet.count - 1) {
                                    if (self.secondSet.count == 0) {
                                        NSLog("Next queued set is empty, ending")
                                        //my 2nd set has nothing in it...
                                        self.firstSet = self.secondSet;
                                        self.backImageView!.image = self.endingImg;
                                        self.atEnd = true;
                                    }
                                    else if (self.loadedCount == self.secondSet.count) {
                                        //my 2nd set is all loaded and I can copy the 2nd set => 1st set and start loading right away
                                        NSLog("Moving 2nd set to 1st, starting queue for new 2nd set")
                                        self.firstSet = self.secondSet;
                                        
                                        //self.loadedSetNum = 2; unnecessary: still loading into set #2
                                        self.loadedCount = 0;    //have 0 images loaded
                                        //start loading another set of images
                                        ServerInteractor.getPost(self.getReturnList, sender: self);
                                        
                                        if (self.firstSet.count > 0) {
                                            //no need to check loading, they should all be loaded
                                            NSLog("Set backimg from next set")
                                            self.backImageView!.image = (self.firstSet[0])!.image;
                                        }
                                        else {
                                            //this should never run, since all images are loaded!
                                            NSLog("All images are loaded, yet we are trying to load an image. WTF?");
                                            self.backImageView!.image = self.loadingImg;
                                        }
                                    }
                                    else {
                                        NSLog("Current set is still loading, now loading first set instead of 2nd")
                                        //my 2nd set is still loading, I need to copy the 2nd set over to the 1st and keep on loading
                                        self.firstSet = self.secondSet;
                                        self.loadedSetNum = 1;
                                        if (self.firstSet.count > 0 && self.loadedSet[0]) {
                                            NSLog("Fortunately backimg was ready for load at index 0")
                                            self.backImageView!.image = (self.firstSet[0])!.image;
                                        }
                                        else {
                                            NSLog("Waiting for backimg to load at 0")
                                            self.backImageView!.image = self.loadingImg;
                                        }
                                    }
                                }
                                else {
                                    NSLog("All first set elements loaded, getting backImg");
                                    self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image;
                                }
                            }
                        }
                        else {
                            NSLog("Resetting content, since queue is stopped");
                            self.resetToStart();
                        }
                        
                        
                        
                        /*
                        if (self.viewCounter == self.firstSet.count - 1) {
                            //need to load image from next set, if there is one
                            if (self.loadedSetNum == 1) {
                                
                            }
                            
                        }
                        else {
                            if (self.loadedSetNum == 1) {
                                if (self.loadedSet[self.viewCounter]) {
                                    self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image;
                                }
                                else {
                                    //notify I am waiting on this image to load
                                    self.needNext = true;
                                    self.backImageView!.image = self.loadingImg;
                                }
                            }
                            else {
                                //fetch back image to show next
                                self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image
                            }
                        }
                        
                        if (self.viewCounter == self.firstSet.count - 1) {
                            self.backImageView!.image = UIImage(named: "daniel-craig.jpg");
                            return;
                        }
                        
                        
                        
                        
                        if (self.viewCounter == (POST_LOAD_COUNT - 1)) {
                            self.backImageView!.image = (self.secondSet[0])!.image
                        } else if (self.viewCounter == POST_LOAD_COUNT) {
                            self.viewCounter = 0;
                            self.backImageView!.image = (self.secondSet[self.viewCounter+1])!.image
                            
                            self.firstSet = self.secondSet;
                            
                            self.numSets += 1
                            ServerInteractor.getPost(getReturnList);
                        } else {
                            self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image
                        }*/
                        
                        
                        /*
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
                        */
                        
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
