//
//  ASNWelcomeViewController.h
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ASNWelcomeViewController : UIViewController <UITextFieldDelegate, MCNearbyServiceBrowserDelegate>
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *visibilityToggle;

@end
