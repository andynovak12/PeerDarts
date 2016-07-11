//
//  UIButton+ASNButtonStyle.m
//  DartsObjC
//
//  Created by Andy Novak on 7/7/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "UIButton+ASNButtonStyle.h"

@implementation UIButton (ASNButtonStyle)

-(void) buttonWithMyStyleAndSizePriority:(enum UIPriority) priority {
    self.backgroundColor = ASNDarkestColor;
    [self setTitleColor:ASNYellowColor forState:normal];
    // change this to adjust the corner radius size
    CGFloat cornerRadiusPercentage = 0.15;
    
    // calculates the smaller side of the button
    CGFloat buttonWidth = self.frame.size.width;
    CGFloat buttonHeight = self.frame.size.height;
    CGFloat smallerSide = 0;
    (buttonWidth > buttonHeight) ? (smallerSide = buttonHeight) : (smallerSide = buttonWidth);
    
    self.layer.cornerRadius = cornerRadiusPercentage * smallerSide;
    
    // shadow
    [ASNUIElements applyShadowTo:self];
    
    if (priority == high) {
        self.titleLabel.font = [UIFont fontWithName:fontName size:35];
        
    }
    else if (priority == medium) {
        self.titleLabel.font = [UIFont fontWithName:fontName size:25];
    }
    else {
        self.titleLabel.font = [UIFont fontWithName:fontName size:12];
    }
}
@end
