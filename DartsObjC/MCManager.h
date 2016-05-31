//
//  MCManager.h
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>


@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
//@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
//-(void)setupMCBrowser;
-(void)setupMCServiceBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;
-(void)advertiseGame:(BOOL)shouldAdvertise;

@end
