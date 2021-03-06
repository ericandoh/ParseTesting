//
//  FindFriendsViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/29/14.
//
//

import UIKit

let SUGGESTED_CELL_IDENTIFIER = "SuggestedFriendCell";
let SEARCH_CELL_IDENTIFIER = "SearchFriendCell";

let SUGGEST_OWNER = "SUGGEST"



class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var suggestedCollectionView: UICollectionView!
    
    @IBOutlet var searchFriendsTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var backImage: BlurringDarkView!
    //@IBOutlet weak var backBlur: UIVisualEffectView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var findFrindsFromFBBtn: UIButton!
    @IBOutlet weak var findFriendsFromContactsBtn: UIButton!
    
    var isSearching: Bool = false;
    var searchTermList: Array<FriendEncapsulator?> = [];
    var currentTerm: String = "";
    
    var suggestedUsers: Array<FriendEncapsulator?> = [];
    var suggestedUserImgs: [String: Array<ImagePostStructure>] = [:];
    var suggestedUserCounts: [String: Int] = [:];
    
    var isLoadingSuggestedFriends: Bool = false;
    
    var friendsToLoad: Int = 0;
    
    var searchingType: SearchUserType = SearchUserType.BY_NAME;
    
    var delayedSearchType: SearchUserType = SearchUserType.BY_NAME;
    
    var maxLoadCount: Int = NUM_TO_SUGGEST;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }
        
        /*someTextField.owner = self;
        
        someTextField.setTextAfterAttributing("spotting the hottest fashion wear of the year #summer #penguin #fun #awesome with my buddies @dog1 @dog2 @asdf @meepmeep #coolbro socool")*/
        
        self.navigationController!.navigationBar.topItem!.title = "Find Friends";
        // Do any additional setup after loading the view.
        if (iOS_VERSION > 7.0) {
            searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        }
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        //self.searchFriendsTableView.rowHeight = UITableViewAutomaticDimension;
        self.searchFriendsTableView.estimatedRowHeight = 50.0;
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "isTapped:");
        tapRecognizer.cancelsTouchesInView = false;
        self.searchFriendsTableView.addGestureRecognizer(tapRecognizer);

        
        self.searchBar.translucent = true;
        self.searchBar.tintColor = UIColor.whiteColor()
        self.searchBar.layer.cornerRadius = 3;
        self.searchBar.layer.backgroundColor = UIColor.clearColor().CGColor;
        self.searchBar.layer.borderWidth=0.75;
        self.searchBar.layer.borderColor = UIColor.whiteColor().CGColor
        self.searchBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default);
        
        var searchBackImg = ServerInteractor.imageWithColorForSearch(UIColor.clearColor(), andHeight: 32);
        self.searchBar.setSearchFieldBackgroundImage(searchBackImg, forState: UIControlState.Normal);
        
        var mainUser = FriendEncapsulator.dequeueFriendEncapsulatorWithID(PFUser.currentUser().objectId)
        /*mainUser.fetchImage({(image: UIImage)->Void in
            self.backImage.image = image;
        });*/
    }
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
/*       searchBar.resignFirstResponder();
        searchBar.text = "";
        isSearching = false;
        searchTermList = [];
        searchFriendsTableView.hidden = true;
        self.setNewBackgroundFor(nil);
        resetAndFetchSuggested();
        
        if (self.backImage.image == nil) {
            var mainUser = FriendEncapsulator.dequeueFriendEncapsulatorWithID(PFUser.currentUser().objectId)
            mainUser.fetchImage({(image: UIImage)->Void in
                //self.backImage.image = image;
                var backImg = image
                if backImg == DEFAULT_USER_ICON {
                    backImg = DEFAULT_USER_ICON_BACK
                }
                self.backImage.setImageAndBlur(backImg);
            });
        }
        
        self.findFrindsFromFBBtn.layer.borderWidth = CGFloat(1.0)
        self.findFrindsFromFBBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.findFriendsFromContactsBtn.layer.borderWidth = CGFloat(1.0)
        self.findFriendsFromContactsBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.backButton.hidden = true
*/
        showSuggestedFriendsCollection()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        suggestedUsers = [];
        searchBar.text = "";
        suggestedCollectionView.reloadData();
        searchFriendsTableView.hidden = true;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backPress(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                self.navigationController!.popViewControllerAnimated(true);
            } else { // back from Find Friends from FB and Contacts
                self.showSuggestedFriendsCollection()
            }
        }
    }
    
    
    @IBAction func sideMenuButtonPress(sender: AnyObject) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count >= 1) {
                //this is the only vc on the stack - move to menu
                (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
            }
        }
    }

    @IBAction func findFriendsFromFB(sender: UIButton) {
        if (!ServerInteractor.isLinkedWithFB()) {
            notLinkedWithFBAlert();
            return;
        }
        
        if (!self.isSearching) {
            self.isSearching = true;
            self.searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
            self.setNewBackgroundFor(searchFriendsTableView);
        }
        searchTermList = [];
        self.currentTerm = "Friends From Facebook";
        self.searchBar.text = self.currentTerm;
        searchingType = SearchUserType.BY_FACEBOOK;
        ServerInteractor.getFBFriendUsers(receiveSizeOfQuery, receiveStringResult, endStringQuery);
        
        backButton.hidden = false
        backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
    }
    
    @IBAction func findFriendsFromContacts(sender: UIButton) {
        if (!self.isSearching) {
            self.isSearching = true;
            self.searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
            self.setNewBackgroundFor(searchFriendsTableView);
        }
        searchTermList = [];
        self.currentTerm = "Friends From Contacts";
        self.searchBar.text = self.currentTerm;
        searchingType = SearchUserType.BY_CONTACTS;
        ServerInteractor.getSearchContacts(receiveSizeOfQuery, receiveStringResult, endStringQuery);
        
        backButton.hidden = false
        backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
    }
    func setNewBackgroundFor(view: UIView?) {
        //sets the background elements to be right behind this view
        if (view == nil) {
            //set background images to wayyy back
            //backImage
            //backBlur
            //self.view.sendSubviewToBack(backBlur);
            self.view.sendSubviewToBack(backImage);
        }
        else {
            self.view.insertSubview(backImage, belowSubview: view!);
            //self.view.insertSubview(backBlur, belowSubview: view!);
            self.view.insertSubview(searchBar, aboveSubview: view!);
        }
    }
    
    func notLinkedWithFBAlert() {
        CompatibleAlertViews.makeNotice("Not linked with FB!", message: "This account is not linked with Facebook! Go to settings to link your account with Facebook", presenter: self);
        //var alert = UIAlertController(title: "Not linked with FB!", message: "This account is not linked with Facebook! Go to settings to link your account with Facebook", preferredStyle: UIAlertControllerStyle.Alert);
        //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        //self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        if (searchText == "") {
            searchBar.resignFirstResponder();
            if (isSearching) {
                isSearching = false;
                searchTermList = [];
                searchFriendsTableView.hidden = true;
                self.setNewBackgroundFor(nil)
                resetAndFetchSuggested();
                searchBar.resignFirstResponder();
                let delay  = 0.1 * Double(NSEC_PER_SEC);
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    var x = searchBar.resignFirstResponder()
                    }
                );
            }
            return;
        }
        if (!isSearching) {
            isSearching = true;
            //loadFriendList = [];
            searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
            self.setNewBackgroundFor(searchFriendsTableView)

        }
        currentTerm = searchText;
        searchTermList = [];
        searchingType = SearchUserType.BY_NAME;
        ServerInteractor.getSearchUsers(searchText, receiveSizeOfQuery, receiveStringResult, endStringQuery);
    }
    
    func receiveSizeOfQuery(size: Int) {
        searchTermList = Array<FriendEncapsulator?>(count: size, repeatedValue: nil);
        //here or in endStringQuery?
        //yTable.reloadData();
    }
    func receiveStringResult(index: Int, classifier: FriendEncapsulator) {
        searchTermList[index] = classifier;
    }
    func endStringQuery() {
        delayedSearchType = searchingType;
        searchFriendsTableView.reloadData();
    }

    func resetAndFetchSuggested() {
        if (isLoadingSuggestedFriends) {
            //i was loading them before, no need to reset and see new ones!
            return;
        }
        isLoadingSuggestedFriends = true;
        suggestedUsers = [];
        suggestedUserImgs = [:];
        suggestedUserCounts = [:];
        fetchSuggestedUsers();
    }
    
    func fetchSuggestedUsers() {
        self.suggestedCollectionView.reloadData();
        ServerInteractor.getSuggestedFollowers(NUM_TO_SUGGEST,
            retFunction: {
            (retList: Array<FriendEncapsulator?>) in
            self.friendsToLoad = retList.count;
            for (index, friend) in enumerate(retList) {
                self.suggestedUsers.append(friend);
                //self.suggestedUserImgs[friend!.username] = [];
                //self.suggestedUserCounts[friend!.username] = 0;
                ServerInteractor.getSubmissionsForSuggest(MAX_IMGS_PER_SUGGEST, user: friend!, userIndex: index, notifyQueryFinish: self.receiveFinish, finishFunction: self.finishFunction)
            }
        })
    }
    func receiveFinish(userIndex: Int, number: Int) {
        if self.suggestedUsers.isEmpty {
            return
        }
        var friend = self.suggestedUsers[userIndex]!;
        self.suggestedUserImgs[friend.username] = [];
        self.suggestedUserCounts[friend.username] = number;
        if (number == 0) {
            friendsToLoad--;
            if (friendsToLoad == 0) {
                isLoadingSuggestedFriends = false;
            }
        }
    }
    func finishFunction(userIndex: Int, post: ImagePostStructure, index: Int) {
        if self.suggestedUsers.count == 0 {
            return
        }

        var friend = self.suggestedUsers[userIndex]!; // need to check suggestedUsers is empty or not, then access, otherwise will throw an indexing-empty-buffer exception
        
        self.suggestedUserImgs[friend.username]!.append(post);
        
        if (self.suggestedUserImgs[friend.username]!.count == self.suggestedUserCounts[friend.username]!) {
            suggestedCollectionView.reloadData();
            friendsToLoad--;
            if (friendsToLoad == 0) {
                isLoadingSuggestedFriends = false;
            }
            //suggestedCollectionView.reloadSections(NSIndexSet(index: userIndex));
        }
    }
    
    func showSuggestedFriendsCollection() {
        searchBar.resignFirstResponder();
        searchBar.text = "";
        isSearching = false;
        searchTermList = [];
        searchFriendsTableView.hidden = true;
        self.setNewBackgroundFor(nil);
        resetAndFetchSuggested();
        
        if (self.backImage.image == nil) {
            var mainUser = FriendEncapsulator.dequeueFriendEncapsulatorWithID(PFUser.currentUser().objectId)
            mainUser.fetchImage({(image: UIImage)->Void in
                //self.backImage.image = image;
                var backImg = image
                if backImg == DEFAULT_USER_ICON {
                    backImg = DEFAULT_USER_ICON_BACK
                }
                self.backImage.setImageAndBlur(backImg);
            });
        }
        
        self.findFrindsFromFBBtn.layer.borderWidth = CGFloat(1.0)
        self.findFrindsFromFBBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.findFriendsFromContactsBtn.layer.borderWidth = CGFloat(1.0)
        self.findFriendsFromContactsBtn.layer.borderColor = UIColor.whiteColor().CGColor
        self.backButton.hidden = true
    }
    

    //-------------------tableview methods-------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!isSearching) {
            return 0;
        }
        NSLog("-----dagw-------")
        NSLog("%d", searchTermList.count)
        return searchTermList.count;
        
        //return 1 + searchTermList.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchFriendCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        
        // Configure the cell...
        var index: Int = indexPath.row;
        
        if (index < searchTermList.count && searchTermList[index] != nil) {
            //to avoid race conditions
            var friend = searchTermList[index]!;
            var author = searchTermList[index]!.username;
            if (delayedSearchType == SearchUserType.BY_CONTACTS) {
                
                cell.extraConfigurations(friend, message: author, enableFriending: true, sender: self)
                
                friend.getNameWithExtras({(text: String) in
                    cell.descriptionBox.setTextAfterAttributing(true, text: text);
                    //cell.layoutIfNeeded();
                });
                cell.descriptionBox.otherAction = {
                    () in
                    self.pressedTableAt(indexPath);
                }

                
                /*FriendEncapsulator.dequeueFriendEncapsulatorByName(author, {
                    (friend: FriendEncapsulator?) in
                    cell.extraConfigurations(friend!, message: author, enableFriending: true, sender: self)
                    
                    friend!.getNameWithExtras({(text: String) in
                        cell.descriptionBox.setTextAfterAttributing(true, text: text);
                        //cell.layoutIfNeeded();
                    });
                    cell.descriptionBox.otherAction = {
                        () in
                        self.pressedTableAt(indexPath);
                    }
                })*/
                
            }
            else if (delayedSearchType == SearchUserType.BY_FACEBOOK ) {
                
                cell.extraConfigurations(friend, message: author, enableFriending: true, sender: self)
                
                friend.getNameWithExtras({(text: String) in
                    cell.descriptionBox.setTextAfterAttributing(true, text: text);
                    //cell.layoutIfNeeded();
                });
                cell.descriptionBox.otherAction = {
                    () in
                    self.pressedTableAt(indexPath);
                }
                
                /*FriendEncapsulator.dequeueFriendEncapsulatorByName(author, {
                    (friend: FriendEncapsulator?) in
                    cell.extraConfigurations(friend!, message: author, enableFriending: true, sender: self)
                    
                    friend!.getNameWithExtras({(text: String) in
                        cell.descriptionBox.setTextAfterAttributing(true, text: text);
                        //cell.layoutIfNeeded();
                    });
                    cell.descriptionBox.otherAction = {
                        () in
                        self.pressedTableAt(indexPath);
                    }
                })*/
                
                
            }
            else {
                var text = author;
                
                cell.extraConfigurations(friend, message: text, enableFriending: true, sender: self)
                
                /*FriendEncapsulator.dequeueFriendEncapsulatorByName(author, {
                    (friend: FriendEncapsulator?) in
                    cell.extraConfigurations(friend!, message: text, enableFriending: true, sender: self)
                })*/
            }
            
        }
        //if (index == 0) {
            //cell.textLabel.text = "Search for user \"" + currentTerm + "\"";
        //}
        //else {
        
        //}
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int = indexPath.row;
        var recHeight: CGFloat = CGFloat(0);
        if (index < searchTermList.count && searchTermList[index] != nil) {
            //to avoid race conditions
            var friend = searchTermList[index]!;
            var author = searchTermList[index]!.username;
            if (delayedSearchType == SearchUserType.BY_CONTACTS || delayedSearchType == SearchUserType.BY_FACEBOOK ) {
                
                //recHeight will remain 0 if this doesn't return immediately (not in queue)
                //else it'll return immediately with friend name
                recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(friend, message: "\n", enableFriending: true)
                
                /*FriendEncapsulator.dequeueFriendEncapsulatorByName(author, {
                    (friend: FriendEncapsulator?) in
                    recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(friend, message: "\n", enableFriending: true)
                })*/
                
            }
            else {
                var text = author;
                
                recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(friend, message: "\n", enableFriending: true)
                
                /*FriendEncapsulator.dequeueFriendEncapsulatorByName(author, {
                    (friend: FriendEncapsulator?) in
                    recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(friend, message: text, enableFriending: true)
                })*/
            }
        }
        return recHeight;
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (searchingType == SearchUserType.BY_FACEBOOK || searchingType == SearchUserType.BY_CONTACTS) {
            return 80.0;
        }
        
        return 50.0
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pressedTableAt(indexPath);
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        
        FriendEncapsulator.dequeueFriendEncapsulatorByName(searchBar.text.lowercaseString,
        {(friend: FriendEncapsulator?) in
            self.pressedTableAt(friend!)
        })
    }
    func pressedTableAt(indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        var searchResult: String = "";
        var friend: FriendEncapsulator?;
        friend = searchTermList[indexPath.row];
        pressedTableAt(friend!);
    }
    func pressedTableAt(friend: FriendEncapsulator) {
        searchBar.resignFirstResponder();
        //if (index == 0) {
            //searchResult = currentTerm;
            //friend = FriendEncapsulator(friendName: searchResult);
        //}
        //else {
        
        //}
        //startSearch(searchResult);
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
        
        //var friend = FriendEncapsulator(friendName: searchResult);
        
        friend.exists({(result: Bool) in
            if (result) {
                self.searchBar.text = "";
                self.isSearching = false;
                self.searchTermList = [];
                self.searchFriendsTableView.hidden = true;
                self.setNewBackgroundFor(nil);
                var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                self.navigationController!.pushViewController(nextBoard, animated: false);
            }
            else {
                CompatibleAlertViews.makeNotice("No user found!", message: "User \(friend.username) does not exist", presenter: self);
            }
            
        });
    }
    
    //-------------------collectionview methods-------------------
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return suggestedUsers.count;
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var user = suggestedUsers[section];
        var userString: String = user!.username;
        if (suggestedUserImgs[userString] != nil) {
            return (suggestedUserImgs[userString]!).count;
        }
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SuggestedCell", forIndexPath: indexPath) as UICollectionViewCell;
        
        let section = indexPath.section;
        let row = indexPath.row;
        
        var username = suggestedUsers[section]!.username;
        
        var img = (suggestedUserImgs[username]!)[row];
        var backImageView = UIImageView(image: img.getImageAt(0))
        backImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        cell.backgroundView = backImageView;
        
        
        return cell;
        
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView! {
        if (kind == UICollectionElementKindSectionHeader) {
            var reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as SuggestedHeaderView;
            let section = indexPath.section;
            //var username = suggestedUsers[section]!.username;
            
            reusableView.extraConfigurations(suggestedUsers[section]!, sender: self)
            
            return reusableView;
        }
        else {
            var emptyReusableView = UICollectionReusableView();
            return emptyReusableView;
        }
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        //segue to user at that index
        let section = indexPath.section;
        let row = indexPath.row;
        var username = suggestedUsers[section]!.username;
        
        var imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: SUGGEST_OWNER);

        var onlyImagePost = (suggestedUserImgs[username]!)[row];
        imgBuffer.initialSetup4(nil, configureCellFunction: {(Int)->Void in }, alreadyLoadedPosts: [onlyImagePost]);
        var newHome = self.storyboard!.instantiateViewControllerWithIdentifier("Home") as HomeFeedController;
        newHome.syncWithImagePostDelegate(imgBuffer, selectedAt: 0);
        self.navigationController!.pushViewController(newHome, animated: true);
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func isTapped(sender: UITapGestureRecognizer) {
        self.searchBar.resignFirstResponder();
    }
}
