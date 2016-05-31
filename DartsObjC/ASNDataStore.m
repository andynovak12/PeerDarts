//
//  ASNDataStore.m
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNDataStore.h"


@implementation ASNDataStore
@synthesize managedObjectContext = _managedObjectContext;



-(instancetype)init {
    self = [super init];
    if (self) {
        _teams = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Singleton

+ (instancetype)sharedDataStore {
    static ASNDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[ASNDataStore alloc] init];
    });
    
    return _sharedDataStore;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DartsObjC.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DartsObjC" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Fetch/Save

- (void)fetchData
{
    //get messages
    NSFetchRequest *turnsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Turn"];
    
//    NSSortDescriptor *createdAtSorter = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
//    turnsRequest.sortDescriptors = @[createdAtSorter];
    
    self.turns = [self.managedObjectContext executeFetchRequest:turnsRequest error:nil];
    
    //    if ([self.messages count]==0) {
    //        [self generateTestData];
    //    }
//    
//    //get users
//    NSFetchRequest *usersRequest = [NSFetchRequest fetchRequestWithEntityName:@"Recipient"];
//    self.users = [self.managedObjectContext executeFetchRequest:usersRequest error:nil];
//    if ([self.users count]==0) {
//        [self generateTestData];
//    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
//
//#pragma mark - Test data
//
//- (void)generateTestData
//{
//    //make recipients (users)
//    Recipient *Bob = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:self.managedObjectContext];
//    Bob.name = @"Bob";
//    Bob.email = @"bob@bobby.com";
//    Bob.twitterHandle = @"twiit";
//    Bob.phoneNumber = @"94232423";
//    
//    Recipient *Sally = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:self.managedObjectContext];
//    Sally.name = @"Sally";
//    Sally.email = @"sal@gg.df";
//    Sally.twitterHandle = @"sdgdfsdf";
//    Sally.phoneNumber = @"6547658";
//    
//    
//    //make messages
//    Message *messageOne = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
//    messageOne.content = @"Message 1";
//    messageOne.createdAt = [NSDate date];
//    
//    Message *messageTwo = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
//    messageTwo.content = @"Message 2";
//    messageTwo.createdAt = [NSDate date];
//    
//    Message *messageThree = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
//    messageThree.content = @"Message 3";
//    messageThree.createdAt = [NSDate date];
//    
//    //assign messages to recipients
//    [Bob addMessagesOfRecipientObject:messageOne];
//    [Bob addMessagesOfRecipientObject:messageTwo];
//    [Sally addMessagesOfRecipientObject:messageThree];
//    
//    [self saveContext];
//    [self fetchData];
//}

@end

