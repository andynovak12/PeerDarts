//
//  MCManager.m
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "MCManager.h"

@interface MCManager ()

@property (strong, nonatomic) NSArray *arrayInvitationHandler;

@end

@implementation MCManager

-(id)init{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        //        _browser = nil;
        _serviceBrowser = nil;
        _advertiser = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAcceptInvitationNotification:)
                                                     name:@"didAcceptInvitationNotification"
                                                   object:nil];
    }
    
    return self;
}


-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler{
    
    NSUInteger receivedDataUnarchived;
    [context getBytes:&receivedDataUnarchived length:sizeof(receivedDataUnarchived)];
    NSDictionary *dict = @{@"peerID": peerID,
                           @"teamIndex" : @(receivedDataUnarchived)
                           };
    self.arrayInvitationHandler = [NSArray arrayWithObject:[invitationHandler copy]];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveInvitationNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}

// this gets called when user accepts an invitation
-(void)didAcceptInvitationNotification:(NSNotification *)notification {
    void (^invitationHandler)(BOOL, MCSession *) = [self.arrayInvitationHandler objectAtIndex:0];
    invitationHandler(YES, self.session);
    
    NSUInteger teamIndex = [[[notification userInfo] objectForKey:@"teamIndex"] intValue];
    NSData *teamIndexData = [NSData dataWithBytes:&teamIndex length:sizeof(teamIndex)];

    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];

    
    //send to peer that invited index of team to be added to
    NSError *error;
    [self.session sendData:teamIndexData toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }}




-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}



-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName{
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
}


//The serviceType defines the type of service that the browser should look for, and it’s a small text that describes it. This text should be the same for both the browser and the advertiser in order for the first one to be able to discover the second. There are two rules about its name: Must be 1–15 characters long.Can contain only ASCII lowercase letters, numbers, and hyphens.
//-(void)setupMCBrowser{
//    _browser = [[MCBrowserViewController alloc] initWithServiceType:@"darts" session:_session];
//}


-(void)setupMCServiceBrowser {
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"darts"];
}

// this has the serviceType name also
-(void)advertiseSelf:(BOOL)shouldAdvertise{
//    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.peerID.displayName forKey:@"peerInfo"];
    NSMutableDictionary *info = [@{@"peerInfo": self.peerID.displayName ,
                                   @"isGame" : @"no"}
                                       mutableCopy];
    if (shouldAdvertise) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.session.myPeerID discoveryInfo:info serviceType:@"darts"];
//        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithServiceType:@"darts" discoveryInfo:info session:_session];
        [self.advertiser startAdvertisingPeer];
        self.advertiser.delegate = self;
    }
    else{
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
        self.advertiser.delegate = nil;
    }
}

//-(void)advertiseGame:(BOOL)shouldAdvertise{
//    //    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.peerID.displayName forKey:@"peerInfo"];
//    NSMutableDictionary *info = [@{@"peerInfo": [NSString stringWithFormat:@"%@'s Game", self.peerID.displayName] ,
//                                   @"isGame" : @"yes"}
//                                 mutableCopy];
//    if (shouldAdvertise) {
//        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"darts" discoveryInfo:info session:_session];
//        [_advertiser start];
//    }
//    else{
//        [_advertiser stop];
//        _advertiser = nil;
//    }
//}
-(void)advertiseGame:(BOOL)shouldAdvertise{
    //    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.peerID.displayName forKey:@"peerInfo"];
    NSMutableDictionary *info = [@{@"peerInfo": [NSString stringWithFormat:@"%@'s Game", self.peerID.displayName] ,
                                   @"isGame" : @"yes"}
                                 mutableCopy];
    if (shouldAdvertise) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.session.myPeerID discoveryInfo:info serviceType:@"darts"];
        //        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithServiceType:@"darts" discoveryInfo:info session:_session];
        [self.advertiser startAdvertisingPeer];
        self.advertiser.delegate = self;
    }
    else{
        [self.advertiser stopAdvertisingPeer];
        self.advertiser = nil;
        self.advertiser.delegate = nil;
    }
}
@end