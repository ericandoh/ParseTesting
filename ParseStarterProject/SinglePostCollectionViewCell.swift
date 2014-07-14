//
//  SinglePostCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/11/14.
//
//

import UIKit

class SinglePostCollectionViewCell: UICollectionViewCell {
    @IBOutlet var postLabel: UILabel
    @IBOutlet var imageView: UIImageView

    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        //postLabel.text = "Fill me in";
    }
    
    init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder);
        //postLabel.text = "Fill me in";
    }
    
}
