//
//  PhotoPickerViewController.h
//  FashionStash
//
//  Created by Yao Li on 3/10/15.
//
//

#import <UIKit/UIKit.h>

@interface PhotoPickerViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pickBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBtn;
- (IBAction)pickPhotos:(id)sender;
- (IBAction)goToNextPage:(id)sender;

@end
