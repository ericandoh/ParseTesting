//
//  PreviewCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/25/14.
//
//

import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet weak var coveringView: UIView!
    @IBOutlet var label: UILabel!
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder);
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    func darkenImage() {
        coveringView.alpha = 0.7;
    }
    func makeVisible() {
        coveringView.alpha = 0;
    }
    
}
