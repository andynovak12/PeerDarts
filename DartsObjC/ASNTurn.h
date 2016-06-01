//
//  ASNTurn.h
//  DartsObjC
//
//  Created by Andy Novak on 5/31/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASNTurn : NSObject <NSCoding>

@property (nullable, nonatomic, retain) NSDate *timeOfTurn;
@property (nullable, nonatomic, retain) NSMutableDictionary *hits;
@property (nullable, nonatomic, retain) NSString *teamName;

@end
