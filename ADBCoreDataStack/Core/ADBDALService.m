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

- (void)read:(void(^)(NSManagedObjectContext *))changes
{
    NSParameterAssert(changes);
    
    NSManagedObjectContext *context = self.persistenceController.mainContext;
    [context performBlockAndWait:^{ changes(context); }];
}

#pragma mark - ADBCommandModelProtocol

- (void)write:(void(^)(NSManagedObjectContext *))changes
{
    NSParameterAssert(changes);
    
    NSManagedObjectContext *context = [self adb_slaveContext];
    [context performBlockAndWait:^{
        
        changes(context);
        
        NSError *error;
        [context save:&error];
        if (!error)
        {
            [_persistenceController save:nil];
        }
    }];
}

#pragma mark - Private

- (NSManagedObjectContext *)adb_slaveContext
{
    NSManagedObjectContext *slaveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [slaveContext setParentContext:self.persistenceController.mainContext];
    return slaveContext;
}

@end
