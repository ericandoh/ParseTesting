//
//  SearchCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/17/14.
//
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet var postLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder);
    }
}
