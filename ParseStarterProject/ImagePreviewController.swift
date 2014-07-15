//
//  ImagePreviewController.swift
//  ParseStarterProject
//
//  Previews the image before user submission, after image selection
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

@objc
class ImagePreviewController: UIViewController {

    @IBOutlet var exclusiveOptionPanel: UISegmentedControl
    @IBOutlet var imageView: UIImageView;
    @IBOutlet var scrollView: UIScrollView
    
    weak var receivedImage: UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if receivedImage {
            imageView.image = receivedImage;
        }
    }
    
    //function triggered by pushing check button
    @IBAction func acceptImage(sender: UIButton) {
        //store image and submit (BACKEND)
        var choice = exclusiveOptionPanel.selectedSegmentIndex;
        var exclusivity: PostExclusivity = PostExclusivity.EVERYONE;
        switch choice {
            case 1:
                exclusivity = PostExclusivity.FRIENDS_ONLY;
            case 2:
                exclusivity = PostExclusivity.EVERYONE;
            case 3:
                exclusivity = PostExclusivity.MALE_ONLY;
            case 4:
                exclusivity = PostExclusivity.FEMALE_ONLY;
            default:
                exclusivity = PostExclusivity.EVERYONE;
        }
        ServerInteractor.uploadImage(receivedImage!, exclusivity: exclusivity);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func receiveImage(imageValue: UIImage) {
        receivedImage = imageValue
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
