//
//  ADBDALService.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBDALService.h"
#import <CoreData/CoreData.h>

@interface ADBDALService ()

@property (nonatomic, strong) id<ADBPersistenceProtocol> persistenceController;

@end

@implementation ADBDALService

- (instancetype)initWithPersistenceController:(id<ADBPersistenceProtocol>)persistenceController
{
    NSParameterAssert(persistenceController);
    
    self = [super init];
    if (self)
    {
        _persistenceController = persistenceController;
    }
    return self;
}

#pragma mark - ADBQueryModelProtocol

/**
 *  1. always use the main context
 *  2. call either performBlockAndWait: or performBlock: (the block will always be executed on the main theard/queue)
 *  3. execute the fetch request
 *  4. return the results if no error occurred
 */
- (NSArray *)objectsFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSError *error;
    NSManagedObjectContext *main = self.persistenceController.mainContext;
    
    NSArray *results = [main executeFetchRequest:fetchRequest error:&error];
    return results;
}

- (NSManagedObject *)objectFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSError *error;
    NSManagedObjectContext *main = self.persistenceController.mainContext;
    
    NSArray *results = [main executeFetchRequest:fetchRequest error:&error];
    return [results firstObject];
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    return [self.persistenceController.mainContext countForFetchRequest:request error:&error];
}

#pragma mark - ADBCommandModelProtocol

- (void)saveContext:(NSManagedObjectContext *)context
{
    [context performBlock:^{
        
        NSError *error;
        [context save:&error];
        if (!error) {
            [_persistenceController save:nil];
        }
    }];
}

- (void)saveToPersistentStore
{
    return [self saveContext:self.persistenceController.slaveContext];
}

/**
 *  1. use the slave context with a private queue concurrency type, with the main context as parent
 *  2. perform an async block (performBlockAndWait is reentrant) on the created context (it's on a bkg queue but will reuse the main queue if called from the main thread)
 *  3. in the block, execute the actions (changes parameter)
 *  4. save slave context
 *  5. if no saving errors save all the way down to the persistent store via the persistence controller
 *  6. the future is fulfilled after the save is applied to the persistent store.
 */
- (void)writeBlock:(void(^)(NSManagedObjectContext *))changes
{
    NSParameterAssert(changes);
    
    [self.persistenceController.slaveContext performBlockAndWait:^{
        
        changes(_persistenceController.slaveContext);
        
        NSError *error;
        [_persistenceController.slaveContext save:&error];
        if (!error)
        {
            [_persistenceController save:nil];
        }
    }];
}

@end
