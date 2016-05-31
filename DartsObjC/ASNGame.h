//
//  ASNGame.h
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASNTeam.h"
#import "ASNDataStore.h"

@interface ASNGame : NSObject
@property (nonatomic, strong) Player *createdBy;
@property (nonatomic, strong) NSString *gameName;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSMutableArray *teams;

@property (nonatomic, strong) Player *currentPlayer;
@property (nonatomic, strong) ASNTeam *currentTeam;
@property (nonatomic, strong) ASNTeam *previousTeam;
@property (strong, nonatomic) ASNDataStore *dataStore;

- (instancetype) initWithTeams:(NSArray *)teams;
- (void)logTurnOfCurrentPlayer;
-(NSUInteger)addHit:(NSString *)hit toTeamCurrentRound:(ASNTeam *)team;
-(BOOL)isThereAWinner;

@end
