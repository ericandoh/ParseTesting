//
//  SideTableView.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/28/14.
//
//

import UIKit

class SideTableView: UITableView {

    init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder);
        rotateWithFramePreserved();
    }
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        rotateWithFramePreserved();
    }
    func rotateWithFramePreserved() {
        var currentFrame: CGRect = self.frame;
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.frame = CGRectMake(currentFrame.origin.y, currentFrame.origin.x, currentFrame.height, currentFrame.width);
        self.frame = currentFrame;
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
