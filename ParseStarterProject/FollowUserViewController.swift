//
//  FollowUserViewController.swift
//  FashionStash
//
//  Created by Yao Li on 3/23/15.
//
//

import UIKit

let SUGGEST_OWNER = "SUGGEST"

class FollowUserViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var suggestedCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SuggestedCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        return cell
    }
    
    func func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView
    }
}
