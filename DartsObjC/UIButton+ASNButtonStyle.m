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
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    // change this to adjust the corner radius size
    CGFloat cornerRadiusPercentage = 0.15;
    
    // calculates the smaller side of the button
    CGFloat buttonWidth = self.frame.size.width;
    CGFloat buttonHeight = self.frame.size.height;
    CGFloat smallerSide = 0;
    (buttonWidth > buttonHeight) ? (smallerSide = buttonHeight) : (smallerSide = buttonWidth);
    CGFloat buttonRadius = cornerRadiusPercentage * smallerSide;
    if (buttonRadius == 0) {
        self.layer.cornerRadius = 5;
    }
    else {
        self.layer.cornerRadius = cornerRadiusPercentage * smallerSide;
    }
    
    // Gradient
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)ASNMiddleColor.CGColor,
                            (id)ASNDarkColor.CGColor,
                            nil];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    
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
