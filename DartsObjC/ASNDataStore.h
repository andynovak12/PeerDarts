//
//  ASNDataStore.h
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Turn.h"

@interface ASNDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *turns;
@property(strong, nonatomic) NSMutableArray *teams;
+ (instancetype) sharedDataStore;

- (void) saveContext;
//- (void) generateTestData;
- (void) fetchData;

@end
