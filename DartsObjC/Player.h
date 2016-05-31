//
//  Player.h
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Turn;

NS_ASSUME_NONNULL_BEGIN

@interface Player : NSManagedObject

-(void) setupPlayerForRound;
-(void) addHitToCurrentHits:(NSString *)hit;

@end

NS_ASSUME_NONNULL_END

#import "Player+CoreDataProperties.h"
