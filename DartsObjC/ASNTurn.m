//
//  ASNTurn.m
//  DartsObjC
//
//  Created by Andy Novak on 5/31/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNTurn.h"

@implementation ASNTurn

// for converting to NSData
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.timeOfTurn = [coder decodeObjectForKey:@"timeOfTurn"];
        self.hits = [coder decodeObjectForKey:@"hits"];
        self.teamName = [coder decodeObjectForKey:@"teamName"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.timeOfTurn forKey:@"timeOfTurn"];
    [aCoder encodeObject:self.hits forKey:@"hits"];
    [aCoder encodeObject:self.teamName forKey:@"teamName"];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _timeOfTurn = [NSDate new];
        _hits = [NSMutableDictionary new];
        _teamName = @"Team Name";
    }
    return self;
}

@end
