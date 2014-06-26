//STARTING POINT OF APPLICATION (pretty much)

#import <UIKit/UIKit.h>

bool DEBUG_FLAG;

@class ParseStarterProjectViewController;

@interface ParseStarterProjectAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) IBOutlet ParseStarterProjectViewController *viewController;

@end
