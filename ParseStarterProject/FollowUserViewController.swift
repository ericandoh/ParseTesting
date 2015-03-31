//
//  FollowUserViewController.swift
//  FashionStash
//
//  Created by Yao Li on 3/23/15.
//
//

import UIKit

class FollowUserViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SuggestedHeaderViewDelegate {
    @IBOutlet var suggestedCollectionView: UICollectionView!
    @IBOutlet var nextPageButton: UIButton!
    var suggestedUsers : Array<FriendEncapsulator?> = []
    var suggestedUserImgs: [String: Array<ImagePostStructure>] = [:]
    var suggestedUserCounts: [String: Int] = [:]
    
    @IBOutlet var nextPageButtonItem: UIBarButtonItem!
    var isLoadingSuggestedFriends: Bool = false;
    
    var friendsToLoad: Int = 0
    
    var friendsFollowed : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()

        self.navigationController?.navigationItem.hidesBackButton = true

        self.navigationItem.setRightBarButtonItem(nextPageButtonItem, animated: true)
        if (iOS8) {
            self.navigationItem.rightBarButtonItem?.enabled = false
            configNavBarTitle("Choose \(MIN_NUM_USER_TO_FOLLOW) more")
        } else { // iOS 7 and earlier
            configNavBarTitle("Choose at least \(MIN_NUM_USER_TO_FOLLOW)")
        }
        
        resetAndFetchSuggested();
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        self.suggestedCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.suggestedCollectionView.reloadData(); NSLog("current user: \(PFUser.currentUser().objectId) and \(PFUser.currentUser().username)")
        ServerInteractor.getSuggestedFollowers(NUM_TO_SUGGEST,
            retFunction: {
                (retList: Array<FriendEncapsulator?>) in
                self.friendsToLoad = retList.count;
                for (index, friend) in enumerate(retList) {
                    self.suggestedUsers.append(friend);
                    ServerInteractor.getSubmissionsForSuggest(MAX_IMGS_PER_SUGGEST, user: friend!, userIndex: index, notifyQueryFinish: self.receiveFinish, finishFunction: self.finishFunction)
                }
        })
    }
    func receiveFinish(userIndex: Int, number: Int) {
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
        var friend = self.suggestedUsers[userIndex]!; // need to check suggestedUsers is empty or not, then access, otherwise will throw an indexing-empty-buffer exception
        
        self.suggestedUserImgs[friend.username]!.append(post);
        
        if (self.suggestedUserImgs[friend.username]!.count == self.suggestedUserCounts[friend.username]!) {
            suggestedCollectionView.reloadData();
            friendsToLoad--;
            if (friendsToLoad == 0) {
                isLoadingSuggestedFriends = false;
            }
        }
    }
    
    func hideAndDisableRightNavigationItem() { // hide top right next page button
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationController?.navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func showAndEnableRightNavigationItem() { // show top right next page button
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationItem.setRightBarButtonItem(nextPageButtonItem, animated: true)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { 
        return suggestedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var user = suggestedUsers[section];
        var userString: String = user!.username;
        if (suggestedUserImgs[userString] != nil) {
            return (suggestedUserImgs[userString]!).count;
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SuggestedCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        var username = suggestedUsers[section]!.username;
        
        var img = (suggestedUserImgs[username]!)[row];
        var backImageView = UIImageView(image: img.getImageAt(0))
        backImageView.contentMode = UIViewContentMode.ScaleAspectFill;
        cell.backgroundView = backImageView;
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            var reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as SuggestedHeaderView
            let section = indexPath.section
            reusableView.extraConfigurations(suggestedUsers[section]!, sender: self)
            reusableView.delegate = self
            return reusableView
        } else {
            let emptyReusableView = UICollectionReusableView()
            return emptyReusableView
        }
    }
    
    func followUnfollowUser(controller: SuggestedHeaderView, counter: Int) {
        friendsFollowed += counter
        if (iOS8) {
            if (friendsFollowed <= MIN_NUM_USER_TO_FOLLOW) {
                if (friendsFollowed == MIN_NUM_USER_TO_FOLLOW) {
                    configNavBarTitle("Choose 0 more")
                    showAndEnableRightNavigationItem()
                } else {
                    configNavBarTitle("Choose \(MIN_NUM_USER_TO_FOLLOW-friendsFollowed) more")
                    if (friendsFollowed == MIN_NUM_USER_TO_FOLLOW-1) {
                        hideAndDisableRightNavigationItem()
                    }
                }
            }
        }
    }
    @IBAction func goToNextPage(sender: AnyObject) {
        if (iOS7) {
            let followingNum : Int = PFUser.currentUser().objectForKey("followingIds").count
            if (followingNum < MIN_NUM_USER_TO_FOLLOW) {
                CompatibleAlertViews.makeNotice("Follow Users", message: "Choose \(MIN_NUM_USER_TO_FOLLOW - followingNum) more to continue", presenter: self)
                return
            }
        }
        self.performSegueWithIdentifier("JumpIn", sender: self)
    }
    
    func configNavBarTitle(subTitle : String) {
        // config title in nav bar
        let myView : UIView = UIView(frame: CGRectMake(0, 0, 300, 30))
        let title : UILabel = UILabel(frame: CGRectMake(0, 0, 250, 20))
        let titleFollowNumber : UILabel = UILabel(frame: CGRectMake(0, 20, 250, 10))
        
        title.text = "Follow your favorite fashionistas!"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont.boldSystemFontOfSize(CGFloat(12.0))
        title.backgroundColor = UIColor.clearColor()
        
        titleFollowNumber.text = subTitle
        titleFollowNumber.textColor = UIColor.whiteColor()
        titleFollowNumber.font = UIFont.boldSystemFontOfSize(CGFloat(8.0))
        titleFollowNumber.backgroundColor = UIColor.clearColor()
        
        myView.addSubview(title)
        myView.addSubview(titleFollowNumber)
        self.navigationItem.titleView = myView
    }
}
