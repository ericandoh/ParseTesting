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

class HomeFeedController: UIViewController, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    
    //@IBOutlet var commentView: UIView               //use this for hiding and showing
    @IBOutlet var descriptionPage: UIView!
    //@IBOutlet var descriptionTextField: UILabel
    
    @IBOutlet var descriptionTextField: LinkFilledTextView!
    
    @IBOutlet weak var descriptionBackImage: UIImageView!
    
    //@IBOutlet var commentTableView: UITableView     //use this for specific table manipulations
    
    @IBOutlet weak var descripLikeCounter: UIButton!
    
    @IBOutlet weak var descripAgeCounter: UIButton!
    
    @IBOutlet var frontImageView: UIImageView!
    
    @IBOutlet var topLeftButton: UIButton!
    
    @IBOutlet weak var topRightButton: UIButton!
    @IBOutlet var shopTheLookBoxReference: UILabel!
    
    @IBOutlet var homeLookTable: UITableView!
    
    @IBOutlet var shopTheLookPrefacer: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var commentsButton: UIButton!
    
//    @IBOutlet weak var editPostButton: UIButton!
    
    @IBOutlet var shopLookButton: UIButton!
    
    @IBOutlet weak var descripTextViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shopLookHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topPullToRefresh: UILabel!
    
    @IBOutlet weak var bottomPullToRefresh: UILabel!
    
    
    var loadingSpinner: UIActivityIndicatorView?;
    
    var backImageView: UIImageView?;
    
    var noImagesView: UIImageView?;
    
    var swiperNoSwipe: Bool = false;
    var pannerNoPan: Bool = false;
    var swipingRight: Bool = false;
    
    //which image we are viewing currently in firstSet
    var viewCounter = 0;
    
    //which pic in the set of pics of a post I am looking at
    var postCounter = 0;
    
    var refreshNeeded: Bool = false;
    
    var viewingComments: Bool = false;
    
    //var mainUser: FriendEncapsulator = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser());

    var postLoadCount = POST_LOAD_COUNT;
    
    var needLoadOnCurrent: Bool = false;

    
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
    //var commentList: Array<PostComment> = [];
    
    var imgBuffer: CustomImageBuffer?;
    
    var currentShopDelegate: ShopLookDelegate?;
    
    var totalTranslationByPan: CGFloat = CGFloat(0.0);

    var alerter:CompatibleAlertViews?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frontImageView.contentMode = UIViewContentMode.Center;
        
//        editPostButton.hidden = true;
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = false;
        self.navigationController!.view.backgroundColor = UIColor.blackColor();
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        
        //self.navigationController!.navigationBar.barStyle = UIBarStyle.Default
        
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

        loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White);
        loadingSpinner!.center = CGPointMake(FULLSCREEN_WIDTH / 2.0, TRUE_FULLSCREEN_HEIGHT / 2.0);
        loadingSpinner!.hidden = true;
        self.view.insertSubview(loadingSpinner!, atIndex: 0);
        

        //self.navigationTitle.setTitle("", forState: UIControlState.Normal);
        
        //if (self.navigationController) {
            //self.navigationController!.setNavigationBarHidden(true, animated: false);
            //self.navigationController!.navigationBar.hidden = true;
            //self.navigationController!.navigationBar.translucent = true;
            //UIView.setAnimationTransition(UIViewAnimationTransition.None, forView: self.navigationController!.view, cache: true);
        //}
        
        var frame: CGRect = frontImageView.frame;
        //backImageView = UIImageView(frame: frame);
        backImageView = UIImageView(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT))
        backImageView!.hidden = true;
        backImageView!.alpha = 0;
        //backImageView!.contentMode = UIViewContentMode.ScaleAspectFill;
        backImageView!.contentMode = UIViewContentMode.Center;
        self.view.insertSubview(backImageView!, aboveSubview: frontImageView);
        
        if ((imgBuffer) != nil) {
            if (imgBuffer!.isLoadedAt(viewCounter)) {
                configureCurrent(viewCounter);
            }
            if ((!imgBuffer!.didHitEnd()) && imgBuffer!.numItems() - viewCounter < POST_LOAD_LIMIT) {
                if (imgBuffer!.getImagePostAt(viewCounter).myObj.objectId != nil) {
                    imgBuffer!.loadSet();
                }
            }
        }
        
        // Do any additional setup after loading the view.
        descriptionTextField.owner = self;
        self.descriptionTextField.scrollEnabled = true;
        self.descriptionTextField.userInteractionEnabled = true;
        
        //self.view.bringSubviewToFront(frontImageView);
        //commentView.hidden = true; //this should be set in storyboard but just in case
        if (imgBuffer == nil) {
            refresh();
        }
        else {
            if (backImageView == nil || backImageView!.image == nil) {
                setLoadingImage();
            }
            //topLeftButton.setTitle("Back", forState: UIControlState.Normal);
            
            // objectId is nil when current post is just uploaded and in memory instead of parse db
            // we don't want to go back to upload page in that case, so keep logo menu
            if (imgBuffer!.getImagePostAt(viewCounter).myObj.objectId != nil) {
                topLeftButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }
        /*
        var defaults = NSUserDefaults();
        if (defaults.objectForKey("ranTutorial") == nil) {
            defaults.setObject(NSDate(), forKey: "ranTutorial");
            defaults.synchronize();
            //set up tutorial
            var tutorialOverlay = UIButton(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT));
            if (UIScreen.mainScreen().bounds.height == CGFloat(568.0)) {
                tutorialOverlay.setBackgroundImage(TUTORIAL_IMAGE_5, forState: UIControlState.Normal);
            }
            else {
                tutorialOverlay.setBackgroundImage(TUTORIAL_IMAGE_4, forState: UIControlState.Normal);
            }
            tutorialOverlay.addTarget(self, action: "closeTutorial:", forControlEvents: UIControlEvents.TouchDown)
            self.view.addSubview(tutorialOverlay);
            self.view.bringSubviewToFront(tutorialOverlay);
        }*/
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "motionPanned:");
        panGestureRecognizer.delegate = self;
        self.view.addGestureRecognizer(panGestureRecognizer);
        
    }
    override func viewDidAppear(animated: Bool) {
        //check if page needs a refresh
        super.viewDidAppear(animated);
        if (self.navigationController != nil) {
            self.navigationController!.navigationBar.topItem!.title = ""  //crashed here
        }
        //if (self.navigationController) {
            //self.navigationController!.setNavigationBarHidden(true, animated: false);
            //self.navigationController!.navigationBar.hidden = true;
            //self.navigationController!.navigationBar.translucent = true;
        //}
        if (backImageView == nil) {
            var frame: CGRect = frontImageView.frame;
            backImageView = UIImageView(frame: frame);
            backImageView!.hidden = true;
            backImageView!.alpha = 0;
            //backImageView!.contentMode = UIViewContentMode.ScaleAspectFill;
            backImageView!.contentMode = UIViewContentMode.Center;
//            backImageView!.contentMode = UIViewContentMode.ScaleToFill
            self.view.insertSubview(backImageView!, aboveSubview: frontImageView);
        }
        //self.imgBuffer!.loadSet();
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if (backImageView != nil) {
            backImageView!.removeFromSuperview();
        }
        backImageView = nil;
        if (frontImageView.image != nil) {
            frontImageView.image = ServerInteractor.cropImageSoNavigationWorksCorrectly(frontImageView.image!, frame: frontImageView.frame);
        }
        //if (self.navigationController) {
            //self.navigationController!.setNavigationBarHidden(false, animated: false);
            //self.navigationController!.navigationBar.hidden = false;
            //self.navigationController!.navigationBar.translucent = false;
        //}
    }
    /*override func viewWillDisappear(animated: Bool) {
        if (self.navigationController) {
            if (self.navigationController!.viewControllers.bridgeToObjectiveC().indexOfObject(self) == NSNotFound) {
                var lastIndex = self.navigationController!.viewControllers.count - 1;
            }
        }
        super.viewWillDisappear(animated);
    }*/
    func syncWithImagePostDelegate(theirBuffer: CustomImageBuffer, selectedAt: Int) {
        NSLog("Syncing to home at \(selectedAt)")
        viewCounter = selectedAt;
        postCounter = 0;
        refreshNeeded = false;
        viewingComments = false;
        imgBuffer = theirBuffer;
        imgBuffer!.switchContext(HOME_OWNER, nil, configureCellFunction: configureCurrent);
    }
    //to refresh all images in feed
    func refresh() {
        if (noImagesView != nil) {
            noImagesView!.removeFromSuperview();
            noImagesView = nil;
        }
        viewCounter = 0;
        postCounter = 0;
        refreshNeeded = false;
        viewingComments = false;
        setLoadingImage();
        if (imgBuffer != nil) {
            imgBuffer!.resetData();
            imgBuffer!.loadSet();
            if ((imgBuffer) != nil) {
                if (imgBuffer!.isLoadedAt(viewCounter)) {
                    configureCurrent(viewCounter);
                }
            }
            //self.imgBuffer!.loadSet();
            //self.imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: HOME_OWNER);
            //self.imgBuffer!.initialSetup2(ServerInteractor.getPost, refreshFunction: nil, configureCellFunction: configureCurrent);
        }
        else {
            self.imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: HOME_OWNER);
            self.imgBuffer!.initialSetup2(ServerInteractor.getPost, refreshFunction: checkForNoImages, configureCellFunction: configureCurrent);
        }
    }
    
    func checkForNoImages() {
        if (self.imgBuffer!.numItems() == 0) {
            if (loadingSpinner!.hidden == false) {
                self.view.sendSubviewToBack(loadingSpinner!);
                loadingSpinner!.stopAnimating();
                loadingSpinner!.hidden = true;
            }
            //make a view that says we have no images!;
            noImagesView = UIImageView(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, NOBODY_HOME_FEED_BACKGROUND.size.height * FULLSCREEN_WIDTH / NOBODY_HOME_FEED_BACKGROUND.size.width));
            noImagesView!.contentMode = UIViewContentMode.ScaleAspectFit;
            noImagesView!.image = NOBODY_HOME_FEED_BACKGROUND;
            /*noImagesView = UILabel(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT));
            noImagesView!.textColor = UIColor.whiteColor();
            noImagesView!.textAlignment = NSTextAlignment.Center;
            noImagesView!.numberOfLines = 0;
            noImagesView!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            noImagesView!.font = TITLE_TEXT_FONT;
            noImagesView!.text = "You are not following anyone! Open the side menu (top left) and click on \"Find Friends\" to follow people. ";*/
            self.view.addSubview(noImagesView!);
            //self.view.insertSubview(noImagesView, aboveSubview: frontImageView);
            self.view.bringSubviewToFront(noImagesView!);
        }
    }
    
    func setLoadingImage() {
        loadingSpinner!.hidden = false;
        loadingSpinner!.startAnimating();
        self.view.bringSubviewToFront(loadingSpinner!);
        frontImageView!.image = LOADING_IMG;
    }
    func switchImageToLoading(fromDirection: CompassDirection) {
        switchImage(LOADING_IMG, fromDirection: fromDirection);
        loadingSpinner!.hidden = false;
        loadingSpinner!.startAnimating();
        self.view.bringSubviewToFront(loadingSpinner!);
    }
    func switchImage(toImage: UIImage, fromDirection: CompassDirection) {
        
        var toImage = ServerInteractor.cropImageSoWidthIs(toImage, targetWidth: FULLSCREEN_WIDTH);
        
        if (loadingSpinner!.hidden == false) {
            self.view.sendSubviewToBack(loadingSpinner!);
            loadingSpinner!.stopAnimating();
            loadingSpinner!.hidden = true;
        }
        if (backImageView == nil) {
            //var frame: CGRect = frontImageView.frame;
            var frame: CGRect = CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT);
            backImageView = UIImageView(frame: frame);
            backImageView!.hidden = true;
            backImageView!.alpha = 0;
            //backImageView!.contentMode = UIViewContentMode.ScaleAspectFill;
            backImageView!.contentMode = UIViewContentMode.Center;
            self.view.insertSubview(backImageView!, aboveSubview: frontImageView);
        }
        self.backImageView!.image = toImage;
        self.backImageView!.alpha = 0;
        self.backImageView!.hidden = false;
        self.swiperNoSwipe = true;
        if (fromDirection == CompassDirection.STAY) {
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                    self.swiperNoSwipe = false;
                    self.swipingRight = false;
                });
        }
        else if (fromDirection == CompassDirection.EAST) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x + CGFloat(FULLSCREEN_WIDTH), y: oldOrig.y);
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                    self.swiperNoSwipe = false;
                    self.swipingRight = false;
                });
        }
        else if (fromDirection == CompassDirection.WEST) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x - CGFloat(FULLSCREEN_WIDTH), y: oldOrig.y);
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                    self.swiperNoSwipe = false;
                });
        }
        else if (fromDirection == CompassDirection.NORTH) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y - CGFloat(TRUE_FULLSCREEN_HEIGHT));
            self.backImageView!.frame.origin = newOrig;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                    self.swiperNoSwipe = false;
                });
        }
        else if (fromDirection == CompassDirection.SOUTH) {
            var oldOrig = self.backImageView!.frame.origin;
            var newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y + CGFloat(TRUE_FULLSCREEN_HEIGHT));
            self.backImageView!.frame.origin = newOrig;
            //self.backImageView!.alpha = 1;
            UIView.animateWithDuration(0.3, animations: {() in
                self.backImageView!.frame.origin = oldOrig;
                self.backImageView!.alpha = 1;
                }, completion: {(success: Bool) in
                    self.frontImageView!.image = toImage;
                    self.backImageView!.alpha = 0;
                    self.backImageView!.hidden = true;
                    self.swiperNoSwipe = false;
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
        NSLog("Configuring \(index)");

        //configures current image view with assumption that it is already loaded (i.e. loadedPosts[viewCounter] should not be nil)
        var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
        
        // config post authro name, icon, upload creationh time and image page in nav bar
        let myView : UIView = UIView(frame: CGRectMake(0, 0, 300, 30))
        let title : UILabel = UILabel(frame: CGRectMake(60, 0, 300, 20))
        let titleTime : UILabel = UILabel(frame: CGRectMake(60, 20, 50, 10))
        let titlePage : UILabel = UILabel(frame: CGRectMake(115, 20, 50, 10))
        
        title.text = currentPost.getAuthor()
        title.textColor = UIColor.whiteColor()
        title.font = UIFont.boldSystemFontOfSize(CGFloat(12.0))
        title.backgroundColor = UIColor.clearColor()
        
        titleTime.text = currentPost.getAgeAsString() + " ago • "
        titleTime.textColor = UIColor.whiteColor()
        titleTime.font = UIFont.boldSystemFontOfSize(CGFloat(10.0))
        titleTime.backgroundColor = UIColor.clearColor()
        
        titlePage.text = String(postCounter + 1)+"/"+String(currentPost.getImagesCount() + 2);
        titlePage.textColor = UIColor.whiteColor()
        titlePage.font = UIFont.boldSystemFontOfSize(CGFloat(10.0))
        titlePage.backgroundColor = UIColor.clearColor()
        
        let postAuthor = currentPost.getAuthorFriend()
        postAuthor.fetchImage({(image: UIImage)->Void in
            let imageView : UIImageView = UIImageView(image: image)
            
            imageView.frame = CGRectMake(20, 0, 30, 30)
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.layer.masksToBounds = true
            imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            imageView.layer.borderWidth = 0
            
            myView.addSubview(title)
            myView.addSubview(titleTime)
            myView.addSubview(titlePage)
            myView.backgroundColor = UIColor.blackColor()
            myView.addSubview(imageView)
            
            self.navigationItem.titleView = myView
        })

        // config shopLook, like, comment, share info in bottom tool bar
        var numLikes = currentPost.getLikes();
        var numComments = currentPost.getCommentsCount();
        
        var shortenedNumLikeString = ServerInteractor.wordNumberer(numLikes);
        var shortenedNumCommentString = ServerInteractor.wordNumberer(numComments);
        likeButton.setTitle(shortenedNumLikeString, forState: UIControlState.Normal);
        if (currentPost.isLikedByUser()) {
            //likeButton.setTitle("+L:"+shortenedNumLikeString, forState: UIControlState.Normal);
            likeButton.setBackgroundImage(LIKED_HEART, forState: UIControlState.Normal);
        }
        else {
            likeButton.setBackgroundImage(NORMAL_HEART, forState: UIControlState.Normal)
        }
        commentsButton.setTitle(shortenedNumCommentString, forState: UIControlState.Normal);
        
        currentPost.getShopLooksCount() {numShopLooks, error in
            if error == nil {
                self.shopLookButton.setTitle(ServerInteractor.wordNumberer(numShopLooks!), forState: UIControlState.Normal)
            } else {
                self.shopLookButton.setTitle("0", forState: UIControlState.Normal)
            }
        }
 /*
        if (currentPost.isOwnedByMe()) {
            editPostButton.hidden = false;
        }
        else {
            editPostButton.hidden = true;
        }
 */
        //this loads the images
        //2. images are being loaded already (prior call is active)
        //  a. do nothing (callback will get called when needed)
        //3. images need to be loaded
        //  a. load images => when done, if postcounter = 0 => callback function ignores
        //  b. load images => when done, if postcounter != 1 configure
        if (!currentPost.isRestLoaded()) {
            //if postCounter = 0, and I'm looking at it for first time I should start preloading next set of images as well!
            currentPost.loadRestIfNeeded(configureRest, snapShotViewCounter: viewCounter);
        }
        
        if (postCounter == 0) {
            //handled ok, post should be loaded on arrival of this page anyhows
            if (currentPost.image != nil) {
                //most of time should go here
                //our image exists!
                needLoadOnCurrent = false;
                switchImage(currentPost.image!, fromDirection: fromDirection);
            }
            else {
                NSLog("Current Post's image is not loaded despite assumption that it is");
                needLoadOnCurrent = true;
                self.switchImageToLoading(fromDirection);
                var currentVC = self.viewCounter;
                currentPost.loadImage({(imgStruct: ImagePostStructure, index: Int) in
                    if (self.needLoadOnCurrent && index == self.postCounter && currentVC == self.viewCounter) {
                        //this should be 0 (postCounter will be 0)
                        self.switchImage(currentPost.image!, fromDirection: CompassDirection.STAY);
                        self.needLoadOnCurrent = false;
                    }
                }, index: 0);
            }
            //start loading the rest of images while user is still looking at first image
            
            //frontImageView!.image = currentPost.image;
            //stupid nonprogrammers and their 1-based counting system
        }
        else if (postCounter >= currentPost.getImagesCount() + 1) {
            postCounter = currentPost.getImagesCount() + 1;
            self.viewingComments = true;
            //self.frontImageView!.image = oldImg;
            self.startViewingComments(currentPost);
        }
        else {
            if (currentPost.isRestLoaded()) {
                //needLoadOnCurrent = false;
                if (currentPost.isViewingComments(postCounter)) {
                    NSLog("This should not run; block above handles me");
                    self.viewingComments = true;
                    //self.frontImageView!.image = oldImg;
                    self.startViewingComments(currentPost);
                }
                else {
                    self.switchImage(currentPost.getImageAt(postCounter), fromDirection: fromDirection);
                }
            }
            else {
                //switch to a loading image for now, then refresh to the correct image when needed with a transition fade
                //trying to configure at comments, but its not loaded yet!
                self.switchImageToLoading(fromDirection);
            }
        }
    }
    func configureRest(indexAtTimeOfRequest: Int) {
        //if(!needLoadOnCurrent) {
            //return;
        //}
        if (indexAtTimeOfRequest == viewCounter) {
            //im still on the same image post, phew!
            var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
            if (postCounter != 0) {
                //needLoadOnCurrent = false;
                //crash - currentpost doesn't actually have image here!
                self.switchImage(currentPost.getImageAt(postCounter), fromDirection: CompassDirection.STAY);
            }
        }
    }
    func startViewingComments(currentPost: ImagePostStructure) {
        
        if (loadingSpinner!.hidden == false) {
            self.view.sendSubviewToBack(loadingSpinner!);
            loadingSpinner!.stopAnimating();
            loadingSpinner!.hidden = true;
        }
        var imgToDescrip = frontImageView.image;
        descriptionBackImage.image = imgToDescrip!.applyDarkEffect();
        
        //authorTextField.text = currentPost.getAuthor();
        //descriptionTextField.text = currentPost.getDescription();
        
        self.descripTextViewConstraint.constant = MIN_SHOPLOOK_CONSTRAINT;
        self.shopLookHeightConstraint.constant = MIN_SHOPLOOK_CONSTRAINT;
        
        var descripTextToSet = currentPost.getDescriptionWithTag();
        if (descripTextToSet == "") {
            descripTextToSet = "Gallery of images by @"+currentPost.getAuthor();
        }
        descriptionTextField.setTextAfterAttributing(false, text: descripTextToSet);
        var descripPreferredHeight = descriptionTextField.sizeThatFits(CGSizeMake(descriptionTextField.frame.size.width, CGFloat.max)).height;
        var descripHeightToSet = min(descripPreferredHeight, MIN_SHOPLOOK_DESCRIP_CONSTRAINT);
        self.descripTextViewConstraint.constant = descripHeightToSet;
        descriptionTextField.layoutIfNeeded();
        
        currentPost.fetchShopLooks({
            (input: Array<ShopLook>) in
            self.currentShopDelegate = ShopLookDelegate(looks: input, owner: self);
            self.currentShopDelegate!.initialSetup(self.homeLookTable);
            
            var preferredTableHeight = self.homeLookTable.contentSize.height;
            var tableHeightToSet = min(preferredTableHeight, MIN_SHOPLOOK_TOTAL_FLEXIBLE_CONSTRAINT - descripHeightToSet);       //343->300->333
            self.shopLookHeightConstraint.constant = tableHeightToSet;
            
            if (tableHeightToSet == preferredTableHeight && descripHeightToSet != descripPreferredHeight) {
                //table height I set was smaller, so maybe I can expand my descriptiontextfield?
                var descripHeightToSetTry2 = min(descripPreferredHeight, MIN_SHOPLOOK_TOTAL_FLEXIBLE_CONSTRAINT - tableHeightToSet);
                self.descripTextViewConstraint.constant = descripHeightToSetTry2;
                self.descriptionTextField.layoutIfNeeded();
            }
            
            if (input.count == 0) {
                self.shopTheLookPrefacer.hidden = true;
            }
            else {
                self.shopTheLookPrefacer.hidden = false;
            }
            });
        self.descripLikeCounter.setTitle(String(currentPost.getLikes()) + " likes", forState: UIControlState.Normal)
        self.descripAgeCounter.setTitle(currentPost.getAgeAsString(), forState: UIControlState.Normal);
        if (descriptionPage.hidden) {
            descriptionPage.alpha = 0;
            descriptionPage.hidden = false;
            UIView.animateWithDuration(0.3, animations: {() in
                self.descriptionPage.alpha = 1;
                });
            if (ServerInteractor.isAnonLogged()) {
                self.topRightButton.setBackgroundImage(UIImage(), forState: UIControlState.Normal);
            }
            else {
                ServerInteractor.amFollowingUser(currentPost.getAuthorFriend(), retFunction: {(amFollowing: Bool) in
                    if (amFollowing == true) {
                        self.topRightButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
                    }
                    else if (amFollowing == false) {
                        self.topRightButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal);
                    }
                    else {
                        //do nothing, server failed to fetch!
                        NSLog("Failure? \(amFollowing)")
                    }
                });
            }
            
            
            var widthOfTitleBar = TITLE_BAR_WIDTH;
            var widthOfUserIconImg = USER_ICON_WIDTH;
            var heightOfBar = TITLE_BAR_HEIGHT;
            var spacing = TITLE_BAR_ICON_TEXT_SPACING;
            
            var textToPut = currentPost.getAuthor();
            var view: UIView = UIView(frame: CGRectMake(0, 0, widthOfTitleBar, heightOfBar));    //0 0 160 40
            let kNSFontAttributeName = NSString(format: NSFontAttributeName);
            var labelSize = (textToPut as NSString).sizeWithAttributes([kNSFontAttributeName: USER_TITLE_TEXT_FONT]);
            
            var widthOfLabel = min(labelSize.width + 3, widthOfTitleBar - widthOfUserIconImg - spacing);
            var extraMargin = (widthOfTitleBar - widthOfUserIconImg - widthOfLabel - spacing) / 2.0;
            var userIcon = UIImageView(frame: CGRectMake(extraMargin, 0, widthOfUserIconImg, heightOfBar));
            var userLabel: UIButton = UIButton(frame: CGRectMake(spacing + extraMargin + widthOfUserIconImg, 0, widthOfLabel, heightOfBar))
            //userLabel.textColor = TITLE_TEXT_COLOR;
            userLabel.setTitleColor(TITLE_TEXT_COLOR, forState: UIControlState.Normal);
            //userLabel.text = textToPut;
            userLabel.setTitle(textToPut, forState: UIControlState.Normal);
            //userLabel.font = USER_TITLE_TEXT_FONT;
            userLabel.titleLabel!.font = USER_TITLE_TEXT_FONT;
            
            userLabel.addTarget(self, action: "goToCurrentPostAuthor:", forControlEvents: UIControlEvents.TouchDown);
            
            var user = FriendEncapsulator.dequeueFriendEncapsulatorWithID(currentPost.getAuthorID());
            user.fetchImage({(image: UIImage)->Void in
                //self.userIcon.image = image;
                var newUserIcon: UIImage = ServerInteractor.imageWithImage(image, scaledToSize: CGSize(width: widthOfUserIconImg, height: heightOfBar))
                userIcon.image = newUserIcon
                userIcon.layer.cornerRadius = (userIcon.frame.size.width) / 2
                userIcon.layer.masksToBounds = true
                userIcon.layer.borderWidth = 0
                self.navigationItem.titleView = view;
                view.addSubview(userIcon);
                view.addSubview(userLabel);
            });
        }
    }
    
    func hideDescriptionPage() {
        descriptionPage.alpha = 1;
        UIView.animateWithDuration(0.3, animations: {() in
            self.descriptionPage.alpha = 0;
            }, completion: {(success: Bool) in
                self.descriptionPage.hidden = true;
        });
        self.topRightButton.setBackgroundImage(INFO_ICON, forState: UIControlState.Normal);
        self.navigationItem.titleView = UIView();
    }
    
    func goToCurrentPostAuthor(sender: UIButton!) {
        var currentPost = imgBuffer!.getImagePostAt(viewCounter);
        var friend = currentPost.getAuthorFriend();
        friend.exists({(result: Bool) in
            if (result) {
                if (self.navigationController != nil) {  //to avoid race conditions
                    var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                    (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                    self.navigationController!.pushViewController(nextBoard, animated: true);
                }
            }
        });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func swipeUp(sender: UISwipeGestureRecognizer) {
        if (swiperNoSwipe || pannerNoPan) {
            return;
        }
        viewCounter++;
        swipeAction(true);
    }
    
    @IBAction func swipeDown(sender: UISwipeGestureRecognizer) {
        if (swiperNoSwipe || pannerNoPan) {
            return;
        }
        viewCounter--;
        if (viewCounter < 0) {
            viewCounter = 0;
            return;
        }
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
            if (!descriptionPage.hidden) {
                hideDescriptionPage();
            }
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
            if ((self.navigationController) != nil) {
                viewCounter = imgBuffer!.numItems() - 1;
                /*if (imgBuffer!.isLoadedAt(viewCounter)) {
                    var currentPost = imgBuffer!.getImagePostAt(viewCounter);
                    pageCounter.text = String(postCounter + 1)+"/"+String(currentPost.getImagesCount() + 2);
                }*/
                return;
            }
            else {
                refreshNeeded = true;
                switchImage(ENDING_IMG, fromDirection: CompassDirection.SOUTH);
                //frontImageView!.image = ENDING_IMG;
//                pageCounter.text = "0/0";
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
            //frontImageView!.image = LOADING_IMG; commented, 0806
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
        if (swiperNoSwipe || pannerNoPan) {
            return;
        }
        // left swipe in the 1st post image and go to side menu
/*
        if (postCounter == 0) {
            if ((self.navigationController) != nil) {
                (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu()
            }
            else {
                (self.parentViewController as SideMenuManagingViewController).openMenu();
            }
            return;
        }
*/
        if postCounter == 0 {
            return
        }
        postCounter--;
        if (viewingComments) {
            viewingComments = false;
            if (!descriptionPage.hidden) {
                hideDescriptionPage();
            }
            swipeSideAction(CompassDirection.STAY);
            return;
        }
        swipeSideAction(CompassDirection.WEST);
        
    }
    
    //is actually swipe left, but the new image moves in from the right
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        if (swiperNoSwipe || pannerNoPan) {
            return;
        }
        if (viewingComments) {
            return;
        }
        swipingRight = true;
        postCounter++;
        swipeSideAction(CompassDirection.EAST);
    }
    
    @IBAction func sideMenu(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count == 1) {
                //this is the only vc on the stack - move to menu
                (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
            }
            else {
                if (topLeftButton.currentBackgroundImage != BACK_ICON) {
                    (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu()
                } else {
                    self.navigationController!.popViewControllerAnimated(true);
                }
            }
        }
    }
    
    @IBAction func rightSideClicked(sender: UIButton) {
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            return;
        }
        var currentPost = imgBuffer!.getImagePostAt(viewCounter);
        if (postCounter == currentPost.getImagesCount() + 1 && !(ServerInteractor.isAnonLogged())) {
            var userFrdEnc = currentPost.getAuthorFriend();
            ServerInteractor.amFollowingUser(userFrdEnc, retFunction: {(amFollowing: Bool) in
                if (amFollowing == true) {
                    self.alerter = CompatibleAlertViews(presenter: self);
                    self.alerter!.makeNoticeWithAction("Unfollow?", message: "Unfollow this user?", actionName: "Unfollow", buttonAction: {
                        () in
                        ServerInteractor.removeAsFollower(userFrdEnc);
                        //update button
                        self.topRightButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal);
                    });
                    
                    /*let alert: UIAlertController = UIAlertController(title: "Unfollow "+userFrdEnc.username, message: "Unfollow "+userFrdEnc.username+"?", preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        ServerInteractor.removeAsFollower(userFrdEnc);
                        //update button
                        self.topRightButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal);
                    }));
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                        //canceled
                    }));
                    self.presentViewController(alert, animated: true, completion: nil)*/
                }
                else if (amFollowing == false) {
                    //ServerInteractor.postFollowerNotif(userFrdEnc.username, controller: self);
                    ServerInteractor.addAsFollower(userFrdEnc);
                    self.topRightButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
                }
                else {
                    //do nothing, server failed to fetch!
                    NSLog("Failure? \(amFollowing)")
                }
            });
            
        }
        else {
            postCounter = currentPost.getImagesCount() + 1;
            configureCurrent(viewCounter, fromDirection: CompassDirection.WEST);
        }
    }
    
    @IBAction func likePost(sender: UIButton) {
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            return;
        }
        if (imgBuffer!.isLoadedAt(viewCounter)) {
            var post = imgBuffer!.getImagePostAt(viewCounter);
            post.like();
            var shortenedNumLikeString = ServerInteractor.wordNumberer(post.getLikes());
            likeButton.setTitle(shortenedNumLikeString, forState: UIControlState.Normal);
            if (post.isLikedByUser()) {
                //likeButton.setTitle(shortenedNumLikeString, forState: UIControlState.Normal);
                likeButton.setBackgroundImage(LIKED_HEART, forState: UIControlState.Normal)
            }
            else {
                likeButton.setBackgroundImage(NORMAL_HEART, forState: UIControlState.Normal)
            }
            if (viewingComments) {
                self.descripLikeCounter.setTitle(String(post.getLikes()) + " likes", forState: UIControlState.Normal)
            }
        }
        //likePostOutlet.hidden = true
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
        //commentView.hidden = false;
        //self.view.bringSubviewToFront(commentView);
        
        //self.commentList = Array<PostComment>();
        
        
        
        
        
        /*currentPost.fetchComments({(input: NSArray)->Void in
            for index in 0..<input.count {
                self.commentList.append(PostComment(content: (input[input.count - (index + 1)] as String)));
            }
            self.commentTableView.reloadData();
        });*/
        self.performSegueWithIdentifier("ViewCommentsSegue", sender: self);
    }
    
    @IBAction func shareAction(sender: UIButton) {
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            return;
        }
        if (frontImageView.image == LOADING_IMG) {
            //lets not share a loading image...
            return;
        }
        var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
        var contentString: String = "FashionStash - Image Post by user @"+currentPost.getAuthor();
        if (viewingComments) {
            contentString += (": " + currentPost.getDescriptionWithTag())
        }
        var contentImage: UIImage = frontImageView!.image!;
        
        let activityController: UIActivityViewController = UIActivityViewController(activityItems: [contentString, contentImage], applicationActivities: nil);
        self.presentViewController(activityController, animated: true, completion: {
            () in
            //nothing
        });
        
    }
/*
    @IBAction func editPostAction(sender: UIButton) {
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            return;
        }
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Edit Post", "Delete Post");
        //actionSheet.tag = 1;
        actionSheet.showInView(UIApplication.sharedApplication().keyWindow)
        //self.presentViewController(actionSheet, animated: true, completion: {() in });
    }
*/
    
    
    @IBAction func shopLooks(sender: AnyObject) {
        NSLog("Go to shop look page")
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            NSLog("Cancelled");
        case 1:
            //edit this post, segue to imagepreviewcontroller with right specs
            var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
            currentPost.loadAllImages({(result: Array<UIImage>) in
                var imageEditingControl = self.storyboard!.instantiateViewControllerWithIdentifier("ImagePreview") as ImagePreviewController;
                imageEditingControl.receiveImage(result, post: currentPost)
                self.navigationController!.pushViewController(imageEditingControl, animated: true);
            })
        case 2:
            
            alerter = CompatibleAlertViews(presenter: self);
            alerter!.makeNoticeWithAction("Confirm Delete", message: "Deleting this post will delete all images in this post's gallery. Are you sure you want to delete this post?", actionName: "Delete", buttonAction: {
                () in
                var currentPost = self.imgBuffer!.getImagePostAt(self.viewCounter);
                //delete this post!
                ServerInteractor.removePost(currentPost);
            });
            
            /*
            let alert: UIAlertController = UIAlertController(title: "Confirm Delete", message: "Deleting this post will delete all images in this post's gallery. Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!)->Void in
                var currentPost = self.imgBuffer!.getImagePostAt(self.viewCounter);
                //delete this post!
                ServerInteractor.removePost(currentPost);
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!)->Void in
            }));
            self.presentViewController(alert, animated: true, completion: nil);*/
        default:
            break;
        }
    }
    
    @IBAction func viewLikes(sender: UIButton) {
        if (imgBuffer!.numItems() == 0 || self.viewCounter >= imgBuffer!.numItems() || (!self.imgBuffer!.isLoadedAt(self.viewCounter))) {
            //there is no image for this post - no posts on feed
            //or i am at ending page (VC >= post count)
            //no post = no comments
            //this might happen due to network problems
            return;
        }
        var currentPost = self.imgBuffer!.getImagePostAt(viewCounter);
        if (currentPost.getLikes() == 0) {
            return;
        }
        self.performSegueWithIdentifier("ViewLikersSegue", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewCommentsSegue") {
            if (segue.destinationViewController is CommentViewController) {
              //  vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical; // Rises from below
                
                // vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; // Fade
                // vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // Flip
                // vc.modalTransitionStyle = UIModalTransitionStylePartialCurl; // Curl
                
                //[self presentViewController:vc animated:YES completion:nil];
              
                var currentPost: ImagePostStructure = imgBuffer!.getImagePostAt(viewCounter)
                var currentImg = frontImageView.image;
                (segue.destinationViewController as CommentViewController).receiveFromPrevious(currentPost, backgroundImg: currentImg!);
                
                
                /*UIView.animateWithDuration(0.3, animations: {
                    ()->Void in
                    //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    //[self.navigationController pushViewController:nextView animated:NO];
                    //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController!.view cache:NO];
                    UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
                    self.navigationController!.pushViewController(CommentViewController(), animated: false)
                    UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: self.navigationController!.view, cache: false)
                });*/

                //UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"YourStoryboardID"];
                //var controller: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CommentsTestController") as UIViewController
                //controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                //[self presentViewController:controller animated:YES completion:nil];
               // self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        else if (segue.identifier == "ViewLikersSegue") {
            if (segue.destinationViewController is LikedUsersViewController) {
                var currentPost: ImagePostStructure = imgBuffer!.getImagePostAt(viewCounter)
                var currentImg = frontImageView.image;
                (segue.destinationViewController as LikedUsersViewController).receiveFromPrevious(currentPost, backgroundImg: currentImg!);
            }
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        if (otherGestureRecognizer.delegate is HomeFeedController) {
            return true;
        }
        return false;
    }
    func closeTutorial(button: UIButton) {
        UIView.animateWithDuration(0.6, animations: {() in
            button.alpha = 0;
            }, completion: {(success: Bool) in
                button.hidden = true;
                button.removeFromSuperview();
        });
    }
    func motionPanned(sender: UIPanGestureRecognizer) {
        if (swiperNoSwipe) {
            //turn this on as well if I'm redrawing stuff
            return;
        }
        if (viewingComments) {
            return;
        }
        if (swipingRight) {
            return;
        }
        let isRefreshStart = viewCounter == 0;
        let isRefreshEnd = viewCounter >= imgBuffer!.numItems() - 1 && imgBuffer!.didHitEnd();
        if ((!isRefreshStart) && (!isRefreshEnd)) {
            pannerNoPan = false;
        }
        let velocity = sender.velocityInView(self.view);
        if (sender.state == UIGestureRecognizerState.Ended) {
            if ((isRefreshEnd || isRefreshStart) && pannerNoPan) {
                //self.switchImageToLoading(CompassDirection.NORTH);
                pannerNoPan = false;
                swiperNoSwipe = true;
                var referenceY = self.frontImageView!.frame.origin.y;
                var currentY = self.backImageView!.frame.origin.y;
                topPullToRefresh.hidden = true;
                bottomPullToRefresh.hidden = true;
                if (abs(referenceY - currentY) > PULLDOWN_THRESHOLD) {
                    var oldOrig = self.frontImageView.frame.origin;
                    //var newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y - CGFloat(TRUE_FULLSCREEN_HEIGHT));
                    //if (referenceY < currentY) {
                        //newOrig = CGPoint(x: oldOrig.x, y: oldOrig.y + CGFloat(TRUE_FULLSCREEN_HEIGHT));
                    //}
                    var newOrig = self.frontImageView.frame.origin;
                    UIView.animateWithDuration(0.25, animations: {() in
                        self.backImageView!.frame.origin = newOrig;
                        }, completion: {(success: Bool) in
                            self.backImageView!.alpha = 0;
                            self.backImageView!.hidden = true;
                            self.backImageView!.frame.origin = oldOrig;
                            self.backImageView!.image = self.frontImageView.image;
                            self.swiperNoSwipe = false;
                            self.refresh();
                    });
                }
                else {
                    var newOrig = self.frontImageView.frame.origin;
                    UIView.animateWithDuration(0.15, animations: {() in
                        self.backImageView!.frame.origin = newOrig;
                        }, completion: {(success: Bool) in
                            self.frontImageView.image = self.backImageView!.image;
                            self.backImageView!.alpha = 0;
                            self.backImageView!.hidden = true;
                            self.swiperNoSwipe = false;
                    });
                }
            }
        }
        else {
            if (backImageView == nil) {
                //var frame: CGRect = frontImageView.frame;
                var frame: CGRect = CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT);
                backImageView = UIImageView(frame: frame);
                backImageView!.hidden = true;
                backImageView!.alpha = 0;
                //backImageView!.contentMode = UIViewContentMode.ScaleAspectFill;
                backImageView!.contentMode = UIViewContentMode.Center;
                self.view.insertSubview(backImageView!, aboveSubview: frontImageView);
            }
            if (isRefreshStart || isRefreshEnd) {
                if (!pannerNoPan) {
                    //self.backImageView!.image = self.frontImageView!.image;
                    //self.backImageView!.alpha = 1;
                    //self.backImageView!.frame.origin = self.frontImageView!.frame.origin;
                }
                var referenceY = self.frontImageView!.frame.origin.y;
                var oldOrig = self.backImageView!.frame.origin;
                var currentY = oldOrig.y;
                var newY = currentY + velocity.y / 60.0;
                if (newY > referenceY && isRefreshStart) {
                    if (!pannerNoPan) {
                        self.backImageView!.image = self.frontImageView!.image;
                        self.backImageView!.alpha = 1;
                        pannerNoPan = true;
                        self.backImageView!.hidden = false;
                        self.frontImageView.image = LOADING_IMG;
                        topPullToRefresh.hidden = false;
                        self.view.insertSubview(topPullToRefresh, belowSubview: self.backImageView!);
                    }
                    var newOrig = CGPoint(x: oldOrig.x, y: newY);
                    self.backImageView!.frame.origin = newOrig;
                }
                else if (newY < referenceY && isRefreshEnd) {
                    if (!pannerNoPan) {
                        self.backImageView!.image = self.frontImageView!.image;
                        self.backImageView!.alpha = 1;
                        pannerNoPan = true;
                        self.backImageView!.hidden = false;
                        self.frontImageView.image = LOADING_IMG;
                        bottomPullToRefresh.hidden = false;
                        self.view.insertSubview(bottomPullToRefresh, belowSubview: self.backImageView!);
                    }
                    var newOrig = CGPoint(x: oldOrig.x, y: newY);
                    self.backImageView!.frame.origin = newOrig;
                }
            }
        }
    }
    
        /*CATransition* transition = [CATransition animation];
        
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        
        [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
        [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];*/
    
    
    /*@IBAction func exitComments(sender: UIButton) {
        commentView.hidden = true;
        //animate this?
    }*/

    //--------------------TableView delegate methods-------------------------
    
    /*func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        return commentList.count + 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as UITableViewCell
        
        var index: Int = indexPath.row;
        
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = UIFont(name: "Helvetica Neue", size: 17);
        
        if (index == 0) {
            cell.textLabel.text = "Add Comment";
        }
        else {
            
            cell.textLabel.text = commentList[index - 1].commentString;
            mainUser.fetchImage({(image: UIImage)->Void in
                cell.imageView.image = image;
                });
            //cell.imageView.image = PFUser.currentUser()["userIcon"] as UIImage
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
    }*/
}
