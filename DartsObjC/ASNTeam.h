//
//  ASNTeam.h
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface ASNTeam : NSObject <NSCoding>

@property (strong, nonatomic) NSString *teamName;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableDictionary *hitsInCurrentRound;
@property (nonatomic) NSUInteger wins;
@property (nonatomic) NSUInteger loses;
@property (strong, nonatomic) Player *previousPlayer;
@property (nonatomic) NSUInteger scoreOfCurrentRound;
@property (nonatomic) BOOL hasThreeOrMoreOfEveryHit;

- (instancetype) initWithName:(NSString *)teamName;
- (void) addPlayerToTeam:(Player *)player;
- (void) removePlayerFromTeam:(Player *)player;


@end
