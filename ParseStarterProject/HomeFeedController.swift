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
    
    //which image we are viewing currently in firstSet
    var viewCounter = 0;
    
    //first set has images to display, viewCounter tells me where in array I am currently viewing
    var firstSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    //second set should be loaded while viewing first set (load in background), switch to this when we run out in firstSet
    var secondSet: Array<ImagePostStructure?> = Array<ImagePostStructure?>();
    
    //which set of images we are on (so we dont have to query all 2 million images at once)
    var numSets = 0;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        frontImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        backImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 280, height: 320));
        //var imageHorn: UIImage = UIImage(named: "horned-logo.png");
        
        //replace with methods for fetching first two images
        //(BACKEND)
        frontImageView!.image = UIImage(named: "horned-logo.png");
        backImageView!.image = UIImage(named: "test image 3.jpg");
        self.view.addSubview(frontImageView);
        self.view.addSubview(backImageView);
        
        self.view.bringSubviewToFront(frontImageView);
        //removeme
        firstSet = ServerInteractor.getPost(0);
    }
    override func viewDidAppear(animated: Bool) {
        //needs work - reload images back into feed
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
                                //our firstSet is empty - our results have no pictures!
                                //consider resetting numSets back to 0 and repeating our results
                                return;
                            }
                            //reset back to 0, increment set count
                            //numSets++
                            self.viewCounter = 0
                        }
                        else {
                            //register vote back to server
                            if (vote) {
                                //these are causing the object not found for update error
                                self.firstSet[self.viewCounter]!.like();
                            }
                            else {
                                self.firstSet[self.viewCounter]!.pass();
                            }
                        }
                        //NSLog("Updating to image at \(self.viewCounter)")
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
