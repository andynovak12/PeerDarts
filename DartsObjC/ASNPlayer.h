//
//  ASNPlayer.h
//  DartsObjC
//
//  Created by Andy Novak on 5/31/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASNTurn.h"

@interface ASNPlayer : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableDictionary *currentHits;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *turnsOfPlayer;

-(void) setupPlayerForRound;
-(void) addHitToCurrentHits:(NSString *)hit;
-(void)addTurnToPlayer:(ASNTurn *)turn;

@end
