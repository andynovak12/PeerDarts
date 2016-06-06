//
//  ASNHitsContainerViews.m
//  DartsObjC
//
//  Created by Andy Novak on 6/6/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNHitsContainerViews.h"

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
    self.hitImageView = [UIImageView new];
//    self.backgroundColor = [UIColor redColor];
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:self.additionalHitsLabel];
        self.additionalHitsLabel.minimumScaleFactor = 5./self.additionalHitsLabel.font.pointSize;
        self.additionalHitsLabel.adjustsFontSizeToFitWidth = YES;
        self.additionalHitsLabel.textColor = [UIColor whiteColor];
        self.additionalHitsLabel.backgroundColor = [UIColor clearColor];

        [self.additionalHitsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.additionalHitsLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.additionalHitsLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.25].active = YES;
        [self.additionalHitsLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [self.additionalHitsLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.25].active = YES;
        
        [self addSubview:self.hitImageView];
        [self.hitImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.hitImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.hitImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.hitImageView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.hitImageView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
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
