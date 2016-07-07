//
//  ASNAvailableGamesView.m
//  DartsObjC
//
//  Created by Andy Novak on 5/27/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNAvailableGamesView.h"
#import "ASNUIElements.h"
#import "UILabel+ASNLabelStyle.h"

@implementation ASNAvailableGamesView

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
    [ASNUIElements applyShadowTo:self];
    self.layer.cornerRadius = 10;
    self.label = [UILabel new];
    self.label.numberOfLines = 2;
    [self.label labelWithMyStyleAndSizePriority:low];
    self.label.text = @"Loading";
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.adjustsFontSizeToFitWidth = YES;

    
    [self addSubview:self.label];
    [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.label.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.3].active = YES;
    [self.label.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-10].active = YES;
    [self.label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.label.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5].active = YES;
    
    
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"dartboard"];
    self.imageView.tintColor = ASNYellowColor;
    [self addSubview:self.imageView];
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.imageView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.7].active = YES;
    [self.imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [self.imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    self.imageView.userInteractionEnabled = YES;
}

-(void)setPeerID:(MCPeerID *)peerID {
    _peerID = peerID;
    [self updateUI];
}

-(void)updateUI {
    NSString *name = self.peerID.displayName;
    NSUInteger counter = 0;
    if ([name containsString:@" "] && counter == 0) {
        [name stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        counter++;
    }
    self.label.text = name;
}

@end
