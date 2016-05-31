//
//  Player.m
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "Player.h"
#import "Turn.h"

@implementation Player



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

@end
