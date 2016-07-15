//
//  ASNPlayer.m
//  DartsObjC
//
//  Created by Andy Novak on 5/31/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNPlayer.h"

@implementation ASNPlayer

// for converting to NSData
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.currentHits = [coder decodeObjectForKey:@"currentHits"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.turnsOfPlayer = [coder decodeObjectForKey:@"turnsOfPlayer"];
        self.playersPeerID = [coder decodeObjectForKey:@"playersPeerID"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.currentHits forKey:@"currentHits"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.turnsOfPlayer forKey:@"turnsOfPlayer"];
    [aCoder encodeObject:self.playersPeerID forKey:@"playersPeerID"];
}


-(instancetype)init{
    self = [super init];
    if (self) {
        _turnsOfPlayer = [NSMutableArray new];
        _currentHits = [@{@"15" : @0 ,
                           @"16" : @0 ,
                           @"17" : @0 ,
                           @"18" : @0 ,
                           @"19" : @0 ,
                           @"20" : @0 ,
                           @"Bull" : @0
                           } mutableCopy];
        _playersPeerID = nil;
    }
    
    return self;
}

-(void) addHitToCurrentHits:(NSString *)hit{
    NSArray *allowableHits = @[@"15", @"16", @"17", @"18", @"19", @"20", @"Bull"];
    if ([allowableHits containsObject:hit]) {
        NSUInteger previousValue = [((NSMutableDictionary *)self.currentHits)[hit] integerValue];
        ((NSMutableDictionary *)self.currentHits)[hit] = @(previousValue + 1);
    }
    else {
        NSLog(@"wrong input for hit. Allowable inputs are %@", allowableHits);
    }
}

-(void) setupPlayerForRound {
    self.currentHits = [@{@"15" : @0 ,
                          @"16" : @0 ,
                          @"17" : @0 ,
                          @"18" : @0 ,
                          @"19" : @0 ,
                          @"20" : @0 ,
                          @"Bull" : @0
                          } mutableCopy];
}

-(void)addTurnToPlayer:(ASNTurn *)turn {
    [self.turnsOfPlayer addObject:turn];
}

-(void)removePreviousTurn {
    [self.turnsOfPlayer removeLastObject];
    [self setupPlayerForRound];
}

@end
