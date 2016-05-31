//
//  MCManager.m
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager

-(id)init{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        //        _browser = nil;
        _serviceBrowser = nil;
        _advertiser = nil;
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
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"darts" discoveryInfo:info session:_session];
        [_advertiser start];
    }
    else{
        [_advertiser stop];
        _advertiser = nil;
    }
}

-(void)advertiseGame:(BOOL)shouldAdvertise{
    //    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:self.peerID.displayName forKey:@"peerInfo"];
    NSMutableDictionary *info = [@{@"peerInfo": [NSString stringWithFormat:@"%@'s Game", self.peerID.displayName] ,
                                   @"isGame" : @"yes"}
                                 mutableCopy];
    if (shouldAdvertise) {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"darts" discoveryInfo:info session:_session];
        [_advertiser start];
    }
    else{
        [_advertiser stop];
        _advertiser = nil;
    }
}

@end