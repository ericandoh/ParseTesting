//
//  CameraViewController.h
//  TemplateApp
//
//  Controls a image selector that pulls from camera/gallery
//
//  Created by Eric Oh on 6/19/14.
//  Copyright (c) 2014 Sazze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *AnonMessage1;
@property (weak, nonatomic) IBOutlet UILabel *AnonMessage2;

@property (weak, nonatomic) IBOutlet UIButton *gallery;
@property (weak, nonatomic) IBOutlet UIButton *camera;

@property BOOL usingCamera;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *pickedImage;
- (IBAction)useCamera:(id)sender;
- (IBAction)useGallery:(id)sender;

@end
