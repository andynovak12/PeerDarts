//
//  ASNUIElements.m
//  DartsObjC
//
//  Created by Andy Novak on 7/6/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNUIElements.h"

@implementation ASNUIElements

NSString * const fontName = @"Copperplate";
NSString * const fontNameBold = @"Copperplate-Bold";

+(void)applyShadowTo:(UIView *)object {
    object.layer.shadowColor = [UIColor blackColor].CGColor;
    object.layer.shadowOpacity = 0.5;
    object.layer.shadowRadius = 2;
    object.layer.shadowOffset = CGSizeMake(3.0f,3.0f);
}
@end
