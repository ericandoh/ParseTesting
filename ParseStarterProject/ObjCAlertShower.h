//
//  ObjCAlertShower.h
//  FashionStash
//
//  Created by Eric Oh on 8/19/14.
//
//

#import <Foundation/Foundation.h>

@interface ObjCAlertShower : NSObject <UIAlertViewDelegate>

@property UIAlertView *alert;
@property CompatibleAlertViews *owner;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
