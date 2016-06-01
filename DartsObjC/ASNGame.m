//
//  ASNGame.m
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNGame.h"

@implementation ASNGame

- (instancetype)initWithTeams:(NSArray *)teams {
    self = [super init];
    
    if (self) {
        _teams = [teams mutableCopy];
        _currentTeam = teams[0];
        _currentPlayer = ((ASNTeam *)teams[0]).players[0];
        _createdAt = [NSDate date];
        _previousTeam = nil;
        _gameName = @"Game Name";
        
        
        for (ASNTeam *team in teams) {
            [team resetTeam];
        }
    }
    return self;
}

- (void)logTurnOfPlayer:(ASNPlayer *)loggedPlayer {
//    self.dataStore = [ASNDataStore sharedDataStore];
    ASNTurn *playerTurn = [ASNTurn new];
    playerTurn.hits = loggedPlayer.currentHits;
    [loggedPlayer addTurnToPlayer:playerTurn];
//    [self.dataStore saveContext];
}

- (void)logTurnOfCurrentPlayer {
    [self logTurnOfPlayer:self.currentPlayer];
    self.currentTeam.previousPlayer = self.currentPlayer;
    
    
    NSUInteger currentTeamIndex = [self.teams indexOfObject:self.currentTeam];
    NSUInteger nextTeamIndex = (currentTeamIndex + 1) % self.teams.count;
    self.previousTeam = self.currentTeam;
    self.currentTeam = self.teams[nextTeamIndex];
    
    NSUInteger previousPlayerIndex = [self.currentTeam.players indexOfObject:self.currentTeam.previousPlayer];
    self.currentPlayer = self.currentTeam.players[(previousPlayerIndex+1)%self.currentTeam.players.count];
    [self.currentPlayer setupPlayerForRound];
}

-(NSUInteger)addHit:(NSString *)hit toTeamCurrentRound:(ASNTeam *)team {
    NSUInteger teamValueForHit = [team.hitsInCurrentRound[hit] integerValue];
    [team.hitsInCurrentRound setObject:@(teamValueForHit + 1) forKey:hit];
    NSLog(@"New scores for team %@: %@", team.teamName, team.hitsInCurrentRound);
    return teamValueForHit + 1;
}

- (NSMutableDictionary *)addHitsOfPlayer:(ASNPlayer *)player toCurrentRoundHitsOfTeam:(ASNTeam *)team {
    NSMutableDictionary *newTeamHits = [team.hitsInCurrentRound mutableCopy];
    for (NSString *key in player.currentHits) {
        NSUInteger teamValueForKey = [team.hitsInCurrentRound[key] integerValue];
        NSUInteger playerValueForKey = [player.currentHits[key] integerValue];
        newTeamHits[key] = @(teamValueForKey + playerValueForKey);
    }
    return newTeamHits;
}

-(BOOL)teamHasMostPoints:(ASNTeam *)inputtedTeam {
    for (ASNTeam *team in self.teams) {
        if (team == inputtedTeam) {
        }
        else {
            if (team.scoreOfCurrentRound > inputtedTeam.scoreOfCurrentRound) {
                return NO;
            }
        }
    }
    return YES;
}

-(ASNTeam *)returnIfThereIsAWinner {
    for (ASNTeam *team in self.teams) {
        if (team.hasThreeOrMoreOfEveryHit && [self teamHasMostPoints:team]) {
//            NSLog(@"WINNER WINNER %@",team.teamName);
            return team;
        }
    }
    return nil;
}

@end
