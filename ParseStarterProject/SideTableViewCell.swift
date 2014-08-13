//
//  SideTableViewCell.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/28/14.
//
//

import UIKit

class SideTableViewCell: UITableViewCell {
    
    var cellImage: UIImageView?;
    
    //this isnt used cuz of rotation issue :\
    //@IBOutlet weak var previewCellImage: UIImageView!
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder);
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        //var currentFrame: CGRect = self.frame;
        //self.frame = currentFrame;
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var currentFrame: CGRect = self.frame;
        if (cellImage != nil) {
            
        }
        else {
            //cellImage = UIImageView(frame: CGRectMake(0, 0, (currentFrame.width-CGFloat(SIDE_MARGINS * 0)), currentFrame.height));
            //var mainView = UIView(frame: CGRectMake(0, 0, cellImage!.image.size.width, cellImage!.image.size.height));
            cellImage = UIImageView(frame: CGRectMake(0, 0, PREVIEW_CELL_WIDTH, PREVIEW_CELL_HEIGHT));
            cellImage!.contentMode = UIViewContentMode.ScaleAspectFill;
            var mainView = UIView(frame: CGRectMake(0, 0, PREVIEW_CELL_WIDTH, PREVIEW_CELL_HEIGHT));
            mainView.addSubview(cellImage!);
            /*cellImage!.contentMode = UIViewContentMode.ScaleToFill;
            cellImage!.clipsToBounds = true;
            self.contentView.addSubview(cellImage!);*/
            //self.backgroundView = cellImage!;
            self.backgroundView = mainView;
        }
        
        //self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        
        //NSLog("\(currentFrame.origin.x) and \(currentFrame.origin.y)");
        //self.frame = CGRectMake(currentFrame.origin.y, currentFrame.origin.x, currentFrame.height, currentFrame.width);
        //self.frame = currentFrame;
        
        
        /*cellImage.transform = CGAffineTransformMakeRotation(M_PI / 2);
        var currentFrame2: CGRect = cellImage.frame;
        cellImage.frame = CGRectMake(currentFrame2.origin.y, currentFrame2.origin.x, currentFrame2.height, currentFrame2.width);*/
        //cellImage.frame = currentFrame2;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setImage(img: UIImage) {
        var rotImg = UIImage(CGImage: img.CGImage, scale: 0.25, orientation: UIImageOrientation.Right);
        cellImage!.image = rotImg;
        /*previewCellImage.image = rotImg;
        previewCellImage.frame = CGRectMake(-bounds.width / CGFloat(4.0), SIDE_MARGINS, bounds.width, bounds.height - SIDE_MARGINS);
        //self.layoutSubviews();
        //self.contentView.setNeedsLayout();*/
    }
    
    /*override func layoutSubviews() {
        NSLog("laying")
        if (self.editing) {
            NSLog("e");
            super.layoutSubviews();
            //bounds = self.bounds;
            previewCellImage.frame = CGRectMake(-bounds.width / CGFloat(4.0), SIDE_MARGINS, bounds.width, bounds.height - SIDE_MARGINS);
        }
        else {
            NSLog("f")
            super.layoutSubviews();
        }
    }*/

}
