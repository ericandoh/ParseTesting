//
//  HomeFeedController.swift
//  ParseStarterProject
//
//  Displays images on your home feed with voting options
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

class HomeFeedController: UIViewController {
    
    var frontImageView: UIImageView?;
    var backImageView: UIImageView?;
    
    var viewCounter = 0;
    
    
    //first set has images to display, viewCounter tells me where in array I am currently viewing
    var firstSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    //second set should be loaded while viewing first set (load in background), switch to this when we run out in firstSet
    var secondSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    
    /*init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        frontImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        backImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        //var imageHorn: UIImage = UIImage(named: "horned-logo.png");
        
        //replace with methods for fetching first two images
        //(BACKEND)
        frontImageView!.image = UIImage(named: "horned-logo.png");
        backImageView!.image = UIImage(named: "daniel-craig.jpg");
        self.view.addSubview(frontImageView);
        self.view.addSubview(backImageView);
        
        self.view.bringSubviewToFront(frontImageView);
        //removeme
        firstSet = ServerInteractor.getPost(0);

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        var location: CGPoint = sender.locationInView(self.view);
        location.x -= 220;
        
        animateImageMotion(location, vote: false);
    }
    
    func animateImageMotion(towardPoint: CGPoint, vote: Bool) {
        if let frontView = frontImageView {
            UIView.animateWithDuration(0.5, animations: {
                frontView.alpha = 0.0;
                frontView.center = towardPoint;
                }
                , completion: { completed in
                    //register vote to backend (BACKEND)
                    //set frontView's image to backView's image
                    if let backView = self.backImageView {
                        frontView.image = backView.image;
                        //reset frontView back to front
                        frontView.frame = CGRect(x: 20, y: 20, width: 280, height: 320);
                        frontView.alpha = 1.0;
                        //fetch new backView image for backView
                        //backView.image = METHOD FOR INSERTING NEW IMAGE HERE (BACKEND)
                        //removeme commented below line
                        //backView.image = UIImage(named: "test image 3.jpg");
                        //removeme
                        if (self.firstSet[self.viewCounter] == nil) {
                            if (self.viewCounter == 0) {
                                return;
                            }
                            self.viewCounter = 0
                        }
                        NSLog("Updating to image at \(self.viewCounter)")
                        var img : UIImage = (self.firstSet[self.viewCounter])!.image!
                        backView.image = img;
                        self.viewCounter = (self.viewCounter + 1)%(POST_LOAD_COUNT);
                        
                    }
                });
        }
    }
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        var location: CGPoint = sender.locationInView(self.view);
        location.x += 220;
        
        animateImageMotion(location, vote: true);
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
