//
//  ASNTeam.m
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNTeam.h"

@implementation ASNTeam


// for converting to NSData
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.teamName = [coder decodeObjectForKey:@"teamName"];
        self.players = [coder decodeObjectForKey:@"players"];
        self.hitsInCurrentRound = [coder decodeObjectForKey:@"hitsInCurrentRound"];
        self.wins = [coder decodeIntegerForKey:@"wins"];
        self.loses = [coder decodeIntegerForKey:@"loses"];
        self.previousPlayer = [coder decodeObjectForKey:@"previousPlayer"];
        self.scoreOfCurrentRound = [coder decodeIntegerForKey:@"scoreOfCurrentRound"];
        self.hasThreeOrMoreOfEveryHit = [coder decodeBoolForKey:@"hasThreeOrMoreOfEveryHit"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.teamName forKey:@"teamName"];
    [aCoder encodeObject:self.players forKey:@"players"];
    [aCoder encodeObject:self.hitsInCurrentRound forKey:@"hitsInCurrentRound"];
    [aCoder encodeInteger:self.wins forKey:@"wins"];
    [aCoder encodeInteger:self.loses forKey:@"loses"];
    [aCoder encodeObject:self.previousPlayer forKey:@"previousPlayer"];
    [aCoder encodeInteger:self.scoreOfCurrentRound forKey:@"scoreOfCurrentRound"];
    [aCoder encodeBool:self.hasThreeOrMoreOfEveryHit forKey:@"hasThreeOrMoreOfEveryHit"];
}


- (instancetype) initWithName:(NSString *)teamName {
    self = [super init];
    
    if (self) {
        _teamName = teamName;
        _wins = 0;
        _loses = 0;
        _players = [NSMutableArray new];
        _hitsInCurrentRound = [@{@"15" : @0,
                                 @"16" : @0,
                                 @"17" : @0,
                                 @"18" : @0,
                                 @"19" : @0,
                                 @"20" : @0,
                                 @"Bull" : @0
        } mutableCopy];
        _scoreOfCurrentRound = 0;
        _previousPlayer = nil;
        _hasThreeOrMoreOfEveryHit = NO;
    }
    
    return self;
}
-(NSUInteger)scoreOfCurrentRound {
    NSUInteger score = 0;
    for (NSString *hit in self.hitsInCurrentRound) {
        if ([hit isEqualToString:@"Bull"]) {
            score += [self.hitsInCurrentRound[hit] integerValue] * 25;
        }
        else {
            score += [self.hitsInCurrentRound[hit] integerValue] * [hit integerValue];
        }
    }
    return score;
}

-(BOOL)hasThreeOrMoreOfEveryHit {
    for (NSString *hit in self.hitsInCurrentRound) {
        if (!([self.hitsInCurrentRound[hit] integerValue] >= 3)) {
            return NO;;
        }
    }
    return YES;
}

- (void) addPlayerToTeam:(Player *)player {
    [self.players addObject:player];
}

- (void) removePlayerFromTeam:(Player *)player {
    if ([self.players containsObject:player]) {
        [self.players removeObject:player];
    }
    else{
        NSLog(@"Player %@ is not on this team", player);
    }
}

@end
