//
//  SideTableView.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/28/14.
//
//

import UIKit

class SideTableView: UITableView {

    required init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder);
        rotateWithFramePreserved();
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        rotateWithFramePreserved();
    }
    override func awakeFromNib() {
        super.awakeFromNib();
        //rotateWithFramePreserved();
    }
    func rotateWithFramePreserved() {
        //self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        //self.autoresizingMask = UIViewAutoresizing.None;
        self.setTranslatesAutoresizingMaskIntoConstraints(true);
        //var superview = self.superview;
        //self.removeFromSuperview()
        var currentFrame: CGRect = self.frame;
        self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI) / 2);
        /*if (iOS8) {
            //self.frame = CGRectMake(currentFrame.origin.y, currentFrame.origin.x, currentFrame.height, currentFrame.width);
            //self.frame = currentFrame;
            self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI) / 2);
        }
        else {
            self.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, currentFrame.width, currentFrame.height);
            self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI) / 2);
            //self.frame = currentFrame;
        }*/
        
        //if (superview != nil) {
            //superview!.addSubview(self);
        //}
        //self.layoutIfNeeded();
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
