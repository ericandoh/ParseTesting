//
//  FollowUserViewController.swift
//  FashionStash
//
//  Created by Yao Li on 3/23/15.
//
//

import UIKit

class FollowUserViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var suggestedCollectionView: UICollectionView!
    var suggestedUsers : Array<FriendEncapsulator?> = []
    var suggestedUserImgs: [String: Array<ImagePostStructure>] = [:]
    var suggestedUserCounts: [String: Int] = [:]
    
    var isLoadingSuggestedFriends: Bool = false;
    
    var friendsToLoad: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);

        resetAndFetchSuggested();
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
        self.suggestedCollectionView.reloadData();
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
        return reusableView
        } else {
            let emptyReusableView = UICollectionReusableView()
            return emptyReusableView
        }
    }
}
