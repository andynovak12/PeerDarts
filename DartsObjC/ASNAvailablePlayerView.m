//
//  ASNAvailablePlayerView.m
//  DartsObjC
//
//  Created by Andy Novak on 5/27/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNAvailablePlayerView.h"
#import "ASNUIElements.h"

@implementation ASNAvailablePlayerView

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
    self.backgroundColor = ASNDarkestColor;
    self.label = [UILabel new];
    [ASNUIElements applyShadowTo:self];
    self.label.text = @"Loading";
    self.label.adjustsFontSizeToFitWidth = YES;

    [self addSubview:self.label];
    [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.label.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.3].active = YES;
    [self.label.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.label.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    
    
    self.imageView = [UIImageView new];
    self.imageView.image = [UIImage imageNamed:@"defaultUserImage"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.imageView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.7].active = YES;
    [self.imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    self.imageView.userInteractionEnabled = YES;
    
    
//    CGFloat frameWidth = self.frame.size.width;
//    CGFloat frameHeight = self.frame.size.height;
    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,0,40,40)];
    self.spinner.color = [UIColor blueColor];
    [self addSubview:self.spinner];
}

-(void)setPeerID:(MCPeerID *)peerID {
    _peerID = peerID;
    [self updateUI];
}

-(void)updateUI {
    self.label.text = self.peerID.displayName;
}

@end

