//
//  Player+CoreDataProperties.h
//  DartsObjC
//
//  Created by Andy Novak on 5/24/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface Player (CoreDataProperties)

@property (nullable, nonatomic, retain) id currentHits;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<Turn *> *turnsOfPlayer;

@end

@interface Player (CoreDataGeneratedAccessors)

- (void)insertObject:(Turn *)value inTurnsOfPlayerAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTurnsOfPlayerAtIndex:(NSUInteger)idx;
- (void)insertTurnsOfPlayer:(NSArray<Turn *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTurnsOfPlayerAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTurnsOfPlayerAtIndex:(NSUInteger)idx withObject:(Turn *)value;
- (void)replaceTurnsOfPlayerAtIndexes:(NSIndexSet *)indexes withTurnsOfPlayer:(NSArray<Turn *> *)values;
- (void)addTurnsOfPlayerObject:(Turn *)value;
- (void)removeTurnsOfPlayerObject:(Turn *)value;
- (void)addTurnsOfPlayer:(NSOrderedSet<Turn *> *)values;
- (void)removeTurnsOfPlayer:(NSOrderedSet<Turn *> *)values;

@end

NS_ASSUME_NONNULL_END
