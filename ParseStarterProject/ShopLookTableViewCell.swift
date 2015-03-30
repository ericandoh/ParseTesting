//
//  ShopLookTableViewCell.swift
//  FashionStash
//
//  Created by Yao Li on 3/30/15.
//
//

import UIKit

class ShopLookTableViewCell : UITableViewCell {
    var shopLookURL : String = ""
    @IBAction func goToShopLook(sender: AnyObject) {
        NSLog("go to shop look page: \(shopLookURL)")
        UIApplication.sharedApplication().openURL(NSURL(string: shopLookURL)!)
    }
}
