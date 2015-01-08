//
//  UITextFieldWithInsets.swift
//  FashionStash
//
//  Created by Eric Oh on 1/8/15.
//
//

import UIKit

class UITextFieldWithInsets: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 0);
    }

    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 0);
    }
}
