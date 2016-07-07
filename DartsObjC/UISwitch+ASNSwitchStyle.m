//
//  UISwitch+ASNSwitchStyle.m
//  DartsObjC
//
//  Created by Andy Novak on 7/7/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "UISwitch+ASNSwitchStyle.h"

@implementation UISwitch (ASNSwitchStyle)

-(void) switchWithMyStyle {
    self.onTintColor = ASNYellowColor;
    self.thumbTintColor = ASNLightestColor;
    // shadow
    [ASNUIElements applyShadowTo:self];
}

@end
