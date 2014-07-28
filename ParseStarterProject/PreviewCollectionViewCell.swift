//
//  PreviewCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/25/14.
//
//

import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView
    @IBOutlet var label: UILabel
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder);
    }
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
}
