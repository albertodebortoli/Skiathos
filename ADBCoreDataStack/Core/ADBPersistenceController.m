//
//  ADBPersistenceController.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBPersistenceController.h"

@interface ADBPersistenceController ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;

@property (nonatomic, copy) void (^initCallback)(void);

@end

@implementation ADBPersistenceController

- (id)initWithDataModelFileName:(NSString *)dataModelFileName
{
    return [self initWithDataModelFileName:dataModelFileName callback:nil];
}

- (id)initWithDataModelFileName:(NSString *)dataModelFileName callback:(void(^)(void))callback
{
    self = [super init];
    if (self)
    {
        _initCallback = [callback copy];
        [self _initializeCoreDataWithDataModelFileName:dataModelFileName];
    }
    
    return self;
}

#pragma mark - ADBPersistenceProtocol

- (void)save:(void(^)(NSError *))handler
{
    if (![[self privateContext] hasChanges] && ![[self managedObjectContext] hasChanges]) return;
    
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        BOOL saveOnMainContextSucceeded = [self.managedObjectContext save:&error];
        NSAssert(saveOnMainContextSucceeded, @"Failed to save main context: %@\n%@", error.localizedDescription, error.userInfo);
        
        [[self privateContext] performBlock:^{
            NSError *privateContextError = nil;
            BOOL saveOnPrivateContextSucceeded = [self.privateContext save:&privateContextError];
            NSAssert(saveOnPrivateContextSucceeded, @"Error saving private context: %@\n%@", privateContextError.localizedDescription, privateContextError.userInfo);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler)
                {
                    handler(privateContextError);
                }
            });
        }];
    }];
}

#pragma mark - Private

- (void)_initializeCoreDataWithDataModelFileName:(NSString *)dataModelFileName
{
    NSParameterAssert(dataModelFileName);
    
    if ([self managedObjectContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModelFileName withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(coordinator, @"Failed to initialize coordinator");
    
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    [self setPrivateContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [self.privateContext setPersistentStoreCoordinator:coordinator];
    [self.managedObjectContext setParentContext:[self privateContext]];
    
    void (^privateContextSetupBlock)() = ^{
        NSPersistentStoreCoordinator *psc = [[self privateContext] persistentStoreCoordinator];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE" };
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", dataModelFileName]];
        
        NSError *error = nil;
        NSAssert([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error], @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.initCallback)
            {
                self.initCallback();
            }
        });
    };
    
    if (self.initCallback != nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            privateContextSetupBlock();
        });
    }
    else
    {
        privateContextSetupBlock();
    }
}

@end
