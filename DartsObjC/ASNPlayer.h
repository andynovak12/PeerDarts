//
//  ASNPlayer.h
//  DartsObjC
//
//  Created by Andy Novak on 5/31/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASNTurn.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ASNPlayer : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableDictionary *currentHits;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *turnsOfPlayer;
@property (strong, nonatomic) MCPeerID *playersPeerID;

-(void) setupPlayerForRound;
-(void) addHitToCurrentHits:(NSString *)hit;
-(void) addTurnToPlayer:(ASNTurn *)turn;
-(void)removePreviousTurn;

@end
