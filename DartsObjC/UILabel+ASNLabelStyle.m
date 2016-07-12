//
//  UILabel+ASNLabelStyle.m
//  DartsObjC
//
//  Created by Andy Novak on 7/7/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "UILabel+ASNLabelStyle.h"

@implementation UILabel (ASNLabelStyle)
-(void) labelWithMyStyleAndSizePriority:(enum UIPriority) priority {
    self.textColor = ASNLightestColor;

    self.minimumScaleFactor = 0.4;
    self.adjustsFontSizeToFitWidth = YES;
    
    if (priority == high) {
        self.font = [UIFont fontWithName:fontName size:35];
        
    }
    else if (priority == medium) {
        self.font = [UIFont fontWithName:fontName size:25];
    }
    else {
        self.font = [UIFont fontWithName:fontName size:15];
    }
}
@end
