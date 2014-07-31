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

let HOME_OWNER = "HOME";

class HomeFeedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var commentView: UIView               //use this for hiding and showing
    @IBOutlet var descriptionPage: UIView
    @IBOutlet var authorTextField: UILabel
    @IBOutlet var descriptionTextField: UILabel
    @IBOutlet var commentTableView: UITableView     //use this for specific table manipulations
    @IBOutlet var pageCounter: UILabel
    @IBOutlet var frontImageView: UIImageView
    
    @IBOutlet var topLeftButton: UIButton
    
    @IBOutlet var shopTheLookBoxReference: UILabel
    
    @IBOutlet var homeLookTable: UITableView
    
    @IBOutlet var shopTheLookPrefacer: UILabel
    
    
    var backImageView: UIImageView?;      //deprecated
    
    var swiperNoSwipe: Bool = false;
    
    //which image we are viewing currently in firstSet
    var viewCounter = 0;
    
    //which pic in the set of pics of a post I am looking at
    var postCounter = 0;
    
    var refreshNeeded: Bool = false;
    
    var viewingComments: Bool = false;
    
    var postLoadCount = POST_LOAD_COUNT;
    
    /*
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
    */
    
    //an array of comments which will be populated when loading app
    var commentList: Array<PostComment> = [];
    
    var imgBuffer: CustomImageBuffer?;
    
    var currentShopDelegate: ShopLookDelegate?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //self.view.bringSubviewToFront(frontImageView);
        commentView.hidden = true; //this should be set in storyboard but just in case
        if (!imgBuffer) {
            refresh();
        }
        else {
            frontImageView!.image = LOADING_IMG;
            topLeftButton.setTitle("Back", forState: UIControlState.Normal);
        }
        
        var frame: CGRect = frontImageView.frame;
        backImageView = UIImageView(frame: frame);
        backImageView!.hidden = true;
        backImageView!.alpha = 0;
        backImageView!.contentMode = UIViewContentMode.ScaleAspectFill;
        self.view.insertSubview(backImageView!, aboveSubview: frontImageView);
    }
    override func viewDidAppear(animated: Bool) {
        //frontImageView!.image = LOADING_IMG;
        //check if page needs a refresh
        super.viewDidAppear(animated);
        if (self.navigationController) {
            self.navigationController.setNavigationBarHidden(true, animated: animated);
        }
        
        if (imgBuffer) {
            if (imgBuffer!.isLoadedAt(viewCounter)) {
                configureCurrent(viewCounter);
            }
        }
        //self.imgBuffer!.loadSet();
    }
    override func viewWillDisappear(animated: Bool) {
        if (self.navigationController) {
            self.navigationController.setNavigationBarHidden(false, animated: animated);
        }
    }
    /*override func viewWillDisappear(animated: Bool) {
        if (self.navigationController) {
            if (self.navigationController.viewControllers.bridgeToObjectiveC().indexOfObject(self) == NSNotFound) {
                var lastIndex = self.navigationController.viewControllers.count - 1;
            }
        }
        super.viewWillDisappear(animated);
    }*/
    func syncWithImagePostDelegate(theirBuffer: CustomImageBuffer, selectedAt: Int) {
        viewCounter = selectedAt;
        postCounter = 0;
        refreshNeeded = false;
        viewingComments = false;
        imgBuffer = theirBuffer;
        //frontImageView!.image = LOADING_IMG;
        imgBuffer!.switchContext(HOME_OWNER, nil, configureCellFunction: configureCurrent);
    }
    //to refresh all images in feed
    func refresh() {
        viewCounter = 0;
        postCounter = 0;
        refreshNeeded = false;
        viewingComments = false;
        frontImageView!.image = LOADING_IMG;
        if (imgBuffer) {
            imgBuffer!.resetData();
            self.imgBuffer!.loadSet();
        }
        else {
            self.imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: HOME_OWNER);
            self.imgBuffer!.initialSetup2(ServerInteractor.getPost, refreshFunction: nil, configureCellFunction: configureCurrent);
        }
    }
    
    func switchImage(toImage: UIImage, fromDirection: CompassDirection) {
        self.backImageView!.image = toImage;
        self.backImageView!.alpha = 0;
        self.backImageView!.hidden = false;
        if (fromDirection == CompassDirection.STAY) {
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                });
        }
        else if (fromDirection == CompassDirection.EAST) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x + Double(FULLSCREEN_WIDTH), y: oldOrig.y);
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                });
        }
        else if (fromDirection == CompassDirection.WEST) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x - Double(FULLSCREEN_WIDTH), y: oldOrig.y);
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                });
        }
        else if (fromDirection == CompassDirection.NORTH) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y - Double(FULLSCREEN_WIDTH));
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                });
        }
        else if (fromDirection == CompassDirection.SOUTH) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y + Double(FULLSCREEN_WIDTH));
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                });
        }
    }
    
    //to load another set, if possible
    //build in functionality HERE to make it load other posts (if not loading home screen posts)
    func configureCurrent(index: Int) {
        configureCurrent(index, fromDirection: CompassDirection.STAY);
    }
    func configureCurrent(index: Int, fromDirection: CompassDirection) {
        if (index != viewCounter) {
            return;
        }

        //configures current image view with assumption that it is already loaded (i.e. loadedPosts[viewCounter] should not be nil)
        var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
        pageCounter.text = String(postCounter + 1)+"/"+String(currentPost.getImagesCount() + 2);
        if (postCounter == 0) {
            if (currentPost.image) {
                //most of time should go here
                switchImage(currentPost.image!, fromDirection: fromDirection);
            }
            else {
                NSLog("Caution");
                currentPost.loadImage({(imgStruct: ImagePostStructure, index: Int) in
                    self.switchImage(currentPost.image!, fromDirection: fromDirection);
                }, index: 0);
            }
            //frontImageView!.image = currentPost.image;
            //stupid nonprogrammers and their 1-based counting system
        }
        else {
            var currentPostNum = postCounter;
            var oldImg = self.frontImageView!.image;
            //self.frontImageView!.image = LOADING_IMG;
            currentPost.loadImages({(img: UIImage?, comments: Bool)->Void in
                if (currentPostNum == self.postCounter) {
                    //i haven't swiped more in that time
                    
                    if (comments) {
                        //we have comments! or error :(
                        self.viewingComments = true;
                        //self.frontImageView!.image = oldImg;
                        self.startViewingComments(currentPost);
                    }
                    else {
                        if (img) {
                            self.switchImage(img!, fromDirection: fromDirection);
                        }
                    }
                }

            }, postIndex: postCounter);
        }
    }
    func startViewingComments(currentPost: ImagePostStructure) {
        
        authorTextField.text = currentPost.getAuthor();
        descriptionTextField.text = currentPost.getDescription();
        currentPost.fetchShopLooks({
            (input: Array<ShopLook>) in
            self.currentShopDelegate = ShopLookDelegate(looks: input, owner: self);
            self.currentShopDelegate!.initialSetup(self.homeLookTable);
            if (input.count == 0) {
                self.shopTheLookPrefacer.hidden = true;
            }
            else {
                self.shopTheLookPrefacer.hidden = false;
            }
            });
        
        descriptionPage.alpha = 0;
        descriptionPage.hidden = false;
        UIView.animateWithDuration(0.3, animations: {() in
            self.descriptionPage.alpha = 1;
            });
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func swipeUp(sender: UISwipeGestureRecognizer) {
        viewCounter++;
        swipeAction(true);
    }
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        viewCounter--;
        swipeAction(false);
    }
    
    //actions for swipe Up/Down
    /*
    {
    
        //swipe down
        viewCounter++;
        swipeAction(true);
        //swipe up
    
    
    
    }
    */
    
    //called after viewCounter is changed appropriately
    //motion is true when motion == down
    func swipeAction(motion: Bool) {
        postCounter = 0;
        if (viewingComments) {
            viewingComments = false;
            descriptionPage.alpha = 1;
            UIView.animateWithDuration(0.3, animations: {() in
                self.descriptionPage.alpha = 0;
                }, completion: {(success: Bool) in
                    self.descriptionPage.hidden = true;
                });
        }
        if (refreshNeeded) {
            if (motion) {
                refresh();
                return;
            }
            else {
                refreshNeeded = false;
            }
        }
        
        
        if (viewCounter >= imgBuffer!.numItems()) {
            //show end of file screen, refresh if needed
            if (self.navigationController) {
                viewCounter = imgBuffer!.numItems() - 1;
                return;
            }
            else {
                refreshNeeded = true;
                switchImage(ENDING_IMG, fromDirection: CompassDirection.SOUTH);
                //frontImageView!.image = ENDING_IMG;
                pageCounter.text = "0/0";
            }
        }
        else if (viewCounter < 0) {
            //do nothing
            viewCounter = 0;
        }
        else if (imgBuffer!.isLoadedAt(viewCounter)) {
            //might also need to see if image itself is loaded (depending on changes for deallocing)
            if (motion) {
                configureCurrent(viewCounter, fromDirection: CompassDirection.SOUTH);
            }
            else {
                configureCurrent(viewCounter, fromDirection: CompassDirection.NORTH);
            }
        }
        else {
            //cell will get fetched, wait
            frontImageView!.image = LOADING_IMG;
        }
        
        //load more if necessary
        if ((!imgBuffer!.didHitEnd()) && imgBuffer!.numItems() - viewCounter < POST_LOAD_LIMIT) {
            imgBuffer!.loadSet();
        }
        /*else if () {
            //method for unloading images at start of list - to save memory
            //have a variable to keep track of from which variable we actually have loaded (start at 0, go to 10, 20, etc)
            //only unload images, still keep track of post (is this possible?) => lose reference to parse object, but keep object ID in memory!
        }*/
        
    }
    func swipeSideAction(direction: CompassDirection) {
        if (refreshNeeded) {
            //we are at eof
            postCounter = 0;
            return;
        }
        if (imgBuffer!.isLoadedAt(viewCounter)) {
            configureCurrent(viewCounter, fromDirection: direction);
        }
    }
    
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        if (postCounter == 0) {
            if (self.navigationController) {
                (self.navigationController.parentViewController as SideMenuManagingViewController).openMenu()
            }
            else {
                (self.parentViewController as SideMenuManagingViewController).openMenu();
            }
            return;
        }
        postCounter--;
        if (viewingComments) {
            viewingComments = false;
            descriptionPage.alpha = 1;
            UIView.animateWithDuration(0.3, animations: {() in
                self.descriptionPage.alpha = 0;
                }, completion: {(success: Bool) in
                    self.descriptionPage.hidden = true;
                });
            swipeSideAction(CompassDirection.STAY);
            return;
        }
        swipeSideAction(CompassDirection.WEST);
        
    }
    
    //is actually swipe left, but the new image moves in from the right
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        if (viewingComments) {
            return;
        }
        postCounter++;
        swipeSideAction(CompassDirection.EAST);
    }
    
    @IBAction func sideMenu(sender: UIButton) {
        if (self.navigationController) {
            //(self.navigationController.parentViewController as SideMenuManagingViewController).openMenu()
            self.navigationController.popViewControllerAnimated(true);
        }
        else if (self.parentViewController) {
            (self.parentViewController as SideMenuManagingViewController).openMenu();
        }
    }
    
    func performBufferLog() {
        /*NSLog("----------Logging---------")
        NSLog("VC: \(self.viewCounter) LoadedSetCount: \(self.loadedSet.count)");
        NSLog("FirstSetCount: \(self.firstSet.count) SecondSetCount: \(self.secondSet.count)")
        NSLog("LoadedSetNum: \(self.loadedSetNum)")
        NSLog("First img = loading? \(self.frontImageView!.image == LOADING_IMG)")
        NSLog("Second img = loading? \(self.backImageView!.image == LOADING_IMG)")
        NSLog("----------End Log---------")*/
    }
    /*
    func animateImageMotion(towardPoint: CGPoint, vote: Bool) {
        if (swiperNoSwipe) {
            //in middle of swiping - do nothing
            //later replace this with faster animation
            return;
        }
        swiperNoSwipe = true;
        
        /*
        UIView.animateWithDuration(0.5, animations: {
            frontView.alpha = 0.0;
            frontView.center = towardPoint;
        }
        , completion: { });
        */
        
        
        
                    //register vote to backend (BACKEND)
                    //set frontView's image to backView's image
                    if let backView = self.backImageView {
                        
                        var needRefresh = (frontView.image == ENDING_IMG);
                        frontView.image = backView.image;
                        //reset frontView back to front
                        frontView.frame = CGRect(origin: backView.frame.origin, size: backView.frame.size);
                        frontView.alpha = 1.0;
                        
                        if (!(needRefresh)) {
                            if (vote) {
                                //these are causing the object not found for update error
                                if (self.viewCounter >= self.firstSet.count) {
                                    NSLog("Houston we have a problem");
                                    self.performBufferLog();
                                }
                                self.firstSet[self.viewCounter]!.like();
                                self.voteCounter.textColor = UIColor.greenColor();
                            }
                            else {
                                self.firstSet[self.viewCounter]!.pass();
                                self.voteCounter.textColor = UIColor.redColor();
                            }
                            //mark post as read
                            ServerInteractor.readPost(self.firstSet[self.viewCounter]!);
                            
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
                                    
                                    //actually, this might happen for an image queue size of 1
                                    NSLog("Potential Error: loadedSetNum did not update although list is completely loaded");
                                }
                                else if (self.loadedSet[self.viewCounter+1]) {
                                    self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image;
                                }
                                else {
                                    self.backImageView!.image = LOADING_IMG;
                                }
                            }
                            else {
                                if (self.viewCounter == self.firstSet.count - 1) {
                                    if (self.secondSet.count == 0) {
                                        self.backImageView!.image = ENDING_IMG;
                                        
                                        //this was there before 7/14
                                        if (self.frontImageView!.image == ENDING_IMG) {
                                            self.resetToStart();
                                        }
                                    }
                                    else if (self.loadedCount == self.secondSet.count) {
                                        //no need to check loading, they should all be loaded
                                        self.backImageView!.image = (self.secondSet[0])!.image;
                                    }
                                    else {
                                        if (self.secondSet.count > 0 && self.loadedSet[0]) {
                                            self.backImageView!.image = (self.secondSet[0])!.image;
                                        }
                                        else {
                                            self.backImageView!.image = LOADING_IMG;
                                        }
                                    }
                                }
                                else if (self.viewCounter == 0) {
                                    //only way for this to happen + !atEnd is if we just cycled through and just swiped past the last frame
                                    if (self.secondSet.count == 0) {
                                        //my 2nd set has nothing in it...
                                        self.firstSet = self.secondSet;
                                        self.backImageView!.image = LOADING_IMG;    //from ending
                                        //self.atEnd = true;
                                    }
                                    else if (self.loadedCount == self.secondSet.count) {
                                        //my 2nd set is all loaded and I can copy the 2nd set => 1st set and start loading right away
                                        self.firstSet = self.secondSet;
                                        //start loading another set of images
                                        if (self.firstSet.count > 1) {
                                            self.backImageView!.image = (self.firstSet[1])!.image;
                                            self.getPostCall();
                                        }
                                        else {
                                            //my set only has 1 thing in it
                                            NSLog("Setting as end");
                                            self.backImageView!.image = ENDING_IMG;
                                        }
                                    }
                                    else {
                                        //my 2nd set is still loading, I need to copy the 2nd set over to the 1st and keep on loading
                                        self.firstSet = self.secondSet;
                                        self.loadedSetNum = 1;
                                        if (self.firstSet.count > 1 && self.loadedSet[1]) {
                                            self.backImageView!.image = (self.firstSet[1])!.image;
                                        }
                                        else {
                                            self.backImageView!.image = LOADING_IMG;
                                        }
                                    }
                                }
                                else {
                                    self.backImageView!.image = (self.firstSet[self.viewCounter+1])!.image;
                                }
                            }
                        }
                        else {
                            //tell server to reset
                            self.backImageView!.image = LOADING_IMG;
                            ServerInteractor.resetViewedPosts();
                            self.resetToStart();
                        }
                        if (self.frontImageView!.image == ENDING_IMG) {
                            self.backImageView!.image = LOADING_IMG;
                        }
                        
                    }
                    self.swiperNoSwipe = false;
                });
        }
    }*/
    
    
    @IBAction func likePost(sender: UIButton) {
        if (imgBuffer!.isLoadedAt(viewCounter)) {
            imgBuffer!.getImagePostAt(viewCounter).like();
        }
    }
    
    @IBAction func viewComments(sender: UIButton) {
        //initialize tableview with right arguments
        //load latest 20 comments, load more if requested in cellForRowAtIndexPath        
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            //there is no image for this post - no posts on feed
            //or i am at ending page (VC >= post count)
            //no post = no comments
            //this might happen due to network problems
            return;
        }
        //hide the table view that already exists and re-show it once it is loaded with correct comments
        commentView.hidden = false;
        self.view.bringSubviewToFront(commentView);
        
        NSLog("Comments for \(self.viewCounter)")
        self.commentList = Array<PostComment>();
        
        var currentPost: ImagePostStructure = imgBuffer!.getImagePostAt(viewCounter)
        
        currentPost.fetchComments({(input: NSArray)->Void in
            for index in 0..<input.count {
                self.commentList.append(PostComment(content: (input[index] as String)));
            }
            self.commentTableView.reloadData();
        });
    }
    @IBAction func exitComments(sender: UIButton) {
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
                
                var currentPost: ImagePostStructure = self.imgBuffer!.getImagePostAt(self.viewCounter);
                
                //textFields[0].text
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
        var cellText: NSString?;
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
