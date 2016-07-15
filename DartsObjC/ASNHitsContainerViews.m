//
//  ASNHitsContainerViews.m
//  DartsObjC
//
//  Created by Andy Novak on 6/6/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNHitsContainerViews.h"
#import "UILabel+ASNLabelStyle.h"

@implementation ASNHitsContainerViews

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.additionalHitsLabel = [UILabel new];
    self.hitImageViewTop = [UIImageView new];
    self.hitImageViewMiddle = [UIImageView new];
    self.hitImageViewBottom = [UIImageView new];
//    self.backgroundColor = [UIColor redColor];
    self.hitImageViewsArray = @[self.hitImageViewTop, self.hitImageViewMiddle, self.hitImageViewBottom, self.additionalHitsLabel];
    

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self addSubview:self.hitImageViewBottom];
        [self.hitImageViewBottom setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.hitImageViewBottom.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.hitImageViewBottom.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.hitImageViewBottom.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.hitImageViewBottom.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        self.hitImageViewBottom.image = [UIImage imageNamed:@"ForwardSlash"];
        
        // same as hitImageViewBottom
        [self addSubview:self.hitImageViewMiddle];
        [self.hitImageViewMiddle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.hitImageViewMiddle.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.hitImageViewMiddle.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.hitImageViewMiddle.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.hitImageViewMiddle.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        self.hitImageViewMiddle.image = [UIImage imageNamed:@"BackSlash"];

        // same as hitImageViewBottom
        [self addSubview:self.hitImageViewTop];
        [self.hitImageViewTop setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.hitImageViewTop.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.hitImageViewTop.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.hitImageViewTop.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.hitImageViewTop.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        self.hitImageViewTop.image = [UIImage imageNamed:@"Circle"];

        [self addSubview:self.additionalHitsLabel];
        [self.additionalHitsLabel labelWithMyStyleAndSizePriority:low];
        self.additionalHitsLabel.minimumScaleFactor = 0.3;
        self.additionalHitsLabel.adjustsFontSizeToFitWidth = YES;
        self.additionalHitsLabel.backgroundColor = [UIColor clearColor];
        
        [self.additionalHitsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.additionalHitsLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.additionalHitsLabel.heightAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
        [self.additionalHitsLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.additionalHitsLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
        
        self.hitImageViewTop.hidden = YES;
        self.hitImageViewMiddle.hidden = YES;
        self.hitImageViewBottom.hidden = YES;
        self.hitImageViewTop.contentMode = UIViewContentModeScaleAspectFit;
        self.hitImageViewMiddle.contentMode = UIViewContentModeScaleAspectFit;
        self.hitImageViewBottom.contentMode = UIViewContentModeScaleAspectFit;
    });
    
}

//-(void)setAdditionalHitsLabel:(UILabel *)additionalHitsLabel {
//    _additionalHitsLabel = additionalHitsLabel;
//    [self updateUI];
//}
//
//
//-(void)updateUI {
//    self.label.text = self.peerID.displayName;
//}
//
//-(void)setAdditionalHitsLabel:(UILabel *)additionalHitsLabel {
//    _additionalHitsLabel = additionalHitsLabel;
//    self.additionalHitsLabel.minimumScaleFactor = 5./additionalHitsLabel.font.pointSize;
//    self.additionalHitsLabel.adjustsFontSizeToFitWidth = YES;
//    self.additionalHitsLabel.textColor = [UIColor whiteColor];
//    self.additionalHitsLabel.backgroundColor = [UIColor clearColor];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.superview addSubview:self.additionalHitsLabel];
//        [self.additionalHitsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [self.additionalHitsLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
//        [self.additionalHitsLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.25].active = YES;
//        [self.additionalHitsLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
//        [self.additionalHitsLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
//    });
//    
//}
@end
