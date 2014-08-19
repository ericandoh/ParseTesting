//
//  BlurringDarkView.swift
//  FashionStash
//
//  Created by Eric Oh on 8/18/14.
//
//

import UIKit

class BlurringDarkView: UIImageView {

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder);
        self.initialiseOthers();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initialiseOthers();
    }
    func initialiseOthers() {
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75);
    }
    
    func setImageAndBlur(img: UIImage) {
        var newImg = img.applyDarkEffect();
        self.image = newImg;
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
