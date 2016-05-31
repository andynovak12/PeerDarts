//
//  Turn+CoreDataProperties.h
//  DartsObjC
//
//  Created by Andy Novak on 5/24/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Turn.h"

NS_ASSUME_NONNULL_BEGIN

@interface Turn (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *gameDate;
@property (nullable, nonatomic, retain) id hits;
@property (nullable, nonatomic, retain) NSString *teamName;

@end

NS_ASSUME_NONNULL_END
