//
//  ADBDALService.m
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBDALService.h"
#import <CoreData/CoreData.h>

@interface ADBDALService ()

@property (nonatomic, strong) id<ADBCoreDataStackProtocol> coreDataStack;

@end

@implementation ADBDALService

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSkiathosHandleErrorNotification object:nil];
}

- (instancetype)initWithCoreDataStack:(id<ADBCoreDataStackProtocol>)coreDataStack
{
    NSParameterAssert(coreDataStack);
    
    self = [super init];
    if (self)
    {
        _coreDataStack = coreDataStack;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveErrorNotification:) name:kSkiathosHandleErrorNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - ADBQueryModelProtocol

- (instancetype)read:(Read)statements
{
    NSParameterAssert(statements);
    
    NSManagedObjectContext *context = self.coreDataStack.mainContext;
    [context performBlockAndWait:^{ statements(context); }];
    
    return self;
}

#pragma mark - ADBCommandModelProtocol

- (instancetype)write:(Write)changes
{
    return [self write:changes completion:nil];
}

- (instancetype)write:(Write)changes completion:(void (^)(NSError * _Nullable))handler
{
    NSParameterAssert(changes);
    
    NSManagedObjectContext *context = [self adb_slaveContext];
    [context performBlockAndWait:^{
        
        changes(context);
        
        NSError *error;
        [context save:&error];
        if (!error)
        {
            [_coreDataStack save:handler];
        }
    }];
    
    return self;
}

#pragma mark - Private

- (NSManagedObjectContext *)adb_slaveContext
{
    NSManagedObjectContext *slaveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [slaveContext setParentContext:self.coreDataStack.mainContext];
    return slaveContext;
}

#pragma mark - Errors

- (void)receiveErrorNotification:(NSNotification *)notification
{
    NSError *error = notification.userInfo[@"error"];
    if (error) {
        [self handleError:error];
    }
}

- (void)handleError:(NSError *)error
{
    // override in subclasses
}

@end
