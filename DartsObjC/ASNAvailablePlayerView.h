//
//  ASNAvailablePlayerView.h
//  DartsObjC
//
//  Created by Andy Novak on 5/27/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ASNAvailablePlayerView : UIView

@property(strong,nonatomic)MCPeerID *peerID;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;

@end
