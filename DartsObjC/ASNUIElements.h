//
//  ASNUIElements.h
//  DartsObjC
//
//  Created by Andy Novak on 7/6/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum UIPriority
{
    low,
    medium,
    high
};

@interface ASNUIElements : NSObject


#define ASNLightestColor [UIColor colorWithRed:231/255.0  green:239/255.0 blue:231/255.0 alpha:1]
#define ASNLightColor [UIColor colorWithRed:147/255.0  green:182.0/255.0 blue:145/255.0 alpha:1]
#define ASNMiddleColor [UIColor colorWithRed:86/255.0  green:134/255.0 blue:83/255.0 alpha:1]
#define ASNDarkColor [UIColor colorWithRed:41/255.0  green:91/255.0 blue:38/255.0 alpha:1]
#define ASNDarkestColor [UIColor colorWithRed:6/255.0  green:49/255.0 blue:4/255.0 alpha:1]
#define ASNYellowColor [UIColor colorWithRed:232/255.0  green:206/255.0 blue:24/255.0 alpha:1]


extern NSString * const fontName;
extern NSString * const fontNameBold;

+(void)applyShadowTo:(UIView *)object;

@end
