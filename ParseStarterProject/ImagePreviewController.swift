//
//  ImagePreviewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

@objc
class ImagePreviewController: UIViewController {

    @IBOutlet var imageView: UIImageView;
    
    weak var receivedImage: UIImage?;
    
    /*
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        //imageView = UIImageView();
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if receivedImage {
            imageView.image = receivedImage;
        }
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