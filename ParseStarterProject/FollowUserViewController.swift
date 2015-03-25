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
    var suggestedUsers : Array<FriendEncapsulator?> = []
    var suggestedUserImgs: [String: Array<ImagePostStructure>] = [:]
    var suggestedUserCounts: [String: Int] = [:]
    
    var isLoadingSuggestedFriends: Bool = false;
    
    var friendsToLoad: Int = 0
    
    var friendsFollowed : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()

        var navTitleLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        navTitleLabel.text = "Follow your favorite fashionistas!"
        navTitleLabel.font = UIFont.boldSystemFontOfSize(14.0)
        navTitleLabel.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = navTitleLabel
/*
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
*/
        self.navigationController?.navigationItem.hidesBackButton = true
//        hideAndDisableRightNavigationItem()
        showAndEnableRightNavigationItem()
        
        PFUser.logInWithUsername("123", password: "123")
        
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
//        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
//        self.navigationItem.rightBarButtonItem?.enabled = false
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.setRightBarButtonItem(nil, animated: true)
        self.navigationController?.navigationItem.title = "foo"
        self.navigationItem.title = "Foo"
//        self.navigationItem.setRightBarButtonItem(nil, animated: true)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.navigationBar.setNeedsDisplay();
        NSLog("hide next page button")
    }
    
    func showAndEnableRightNavigationItem() { // show top right next page button
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let nextPageButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_right.png"), style: UIBarButtonItemStyle.Bordered, target: self, action: nil)
        self.navigationItem.setRightBarButtonItem(nextPageButton, animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationController?.navigationItem.setRightBarButtonItem(nextPageButton, animated: true)
        self.navigationController?.navigationItem.title = "bar"
        self.navigationItem.title = "Bar"
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.navigationBar.setNeedsDisplay(); 
        NSLog("show next page button")
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
        friendsFollowed += counter; NSLog("followed friends num :\(friendsFollowed)")
        if (friendsFollowed == 5) {
            showAndEnableRightNavigationItem()
        } else if (friendsFollowed == 4) {
            hideAndDisableRightNavigationItem()
        }
    }
}
