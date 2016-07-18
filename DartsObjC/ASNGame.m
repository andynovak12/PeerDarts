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
    
//  if this is the first player going, and no previousPlayer
    if (self.currentTeam.previousPlayer) {
        NSUInteger previousPlayerIndex = [self.currentTeam.players indexOfObject:self.currentTeam.previousPlayer];
        self.currentPlayer = self.currentTeam.players[(previousPlayerIndex+1)%self.currentTeam.players.count];
    }
    else {
        self.currentPlayer = self.currentTeam.players[0];
    }
    [self.currentPlayer setupPlayerForRound];
}

-(NSUInteger)addHit:(NSString *)hit toTeamCurrentRound:(ASNTeam *)team {
    NSUInteger teamValueForHit = [team.hitsInCurrentRound[hit] integerValue];
    [team.hitsInCurrentRound setObject:@(teamValueForHit + 1) forKey:hit];
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
            return team;
        }
    }
    return nil;
}

-(BOOL)isCurrentTeamsNumberClosed:(NSString *)numberString{
    if (self.teams.count == 1) {
        return NO;
    }
    
    for (ASNTeam *team in self.teams) {
        if (team != self.currentTeam && [team.hitsInCurrentRound[numberString] integerValue] < 3 ) {
            return NO;
        }
    }
    return YES;
}

-(void)undoPreviousTurn {
    if (self.previousTeam.previousPlayer) {

        // remove previous hits from team
        NSDictionary *previousHits = ((ASNTurn *)[self.previousTeam.previousPlayer.turnsOfPlayer lastObject]).hits;

        for (NSString *hit in previousHits) {
            self.previousTeam.hitsInCurrentRound[hit] = [NSString stringWithFormat:@"%ld", [self.previousTeam.hitsInCurrentRound[hit] integerValue] - [previousHits[hit] integerValue]];
            if ([self.previousTeam.hitsInCurrentRound[hit] integerValue] < 0) {
                NSLog(@"here");
            }
        }
        
        
        [self.previousTeam.previousPlayer removePreviousTurn];
        self.currentPlayer = self.previousTeam.previousPlayer;
        
        // Update teams teams
        NSUInteger currentTeamIndex = [self.teams indexOfObject:self.currentTeam];
        NSUInteger previousPreviousTeamIndex = (currentTeamIndex - 2) % self.teams.count;
        self.currentTeam = self.previousTeam;
        self.previousTeam = self.teams[previousPreviousTeamIndex];

    }
    else {
        NSLog(@"There is no prevous player");
    }

    
}

@end
