//
//  ASNHitsContainerViews.h
//  DartsObjC
//
//  Created by Andy Novak on 6/6/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASNHitsContainerViews : UIView
@property (strong, nonatomic) UILabel *additionalHitsLabel;
@property (strong, nonatomic) UIImageView *hitImageViewTop;
@property (strong, nonatomic) UIImageView *hitImageViewMiddle;
@property (strong, nonatomic) UIImageView *hitImageViewBottom;
@property (strong, nonatomic) NSArray *hitImageViewsArray;

@end
