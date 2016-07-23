//
//  ADBPersistenceController.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBPersistenceController.h"

// Vendors
#import <JustPromises/JustPromises.h>

@interface ADBPersistenceController ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *slaveContext;

@end

@implementation ADBPersistenceController

- (id)initSQLiteStoreWithDataModelFileName:(NSString *)dataModelFileName
{
    return [self initSQLiteStoreWithDataModelFileName:dataModelFileName callback:nil];
}

- (id)initSQLiteStoreWithDataModelFileName:(NSString *)dataModelFileName  callback:(void(^)(void))callback
{
    self = [super init];
    if (self)
    {
        [self _initializeSQLiteStoreWithDataModelFileName:dataModelFileName callback:callback];
    }
    
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return _mainContext;
}

#pragma mark - ADBPersistenceProtocol

- (JEFuture *)save
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    __block BOOL mainHasChanges = NO;
    __block BOOL privateHasChanges = NO;
    
    [self.mainContext performBlockAndWait:^{
        mainHasChanges = [self.mainContext hasChanges];
    }];
    
    [self.privateContext performBlockAndWait:^{
        privateHasChanges = [self.privateContext hasChanges];
    }];
    
    if (!mainHasChanges && !privateHasChanges) {
        [promise setResult:@NO];
        return [promise future];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [[self mainContext] performBlock:^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSError *error = nil;
        BOOL saveOnMainContextSucceeded = [strongSelf.mainContext save:&error];
        NSAssert(saveOnMainContextSucceeded, @"Failed to save main context: %@\n%@", error.localizedDescription, error.userInfo);
        
        if (error) {
            [promise setError:error];
            return;
        }
        
        [[self privateContext] performBlock:^{
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSError *privateContextError = nil;
            BOOL saveOnPrivateContextSucceeded = [strongSelf.privateContext save:&privateContextError];
            NSAssert(saveOnPrivateContextSucceeded, @"Error saving private context: %@\n%@", privateContextError.localizedDescription, privateContextError.userInfo);

            if (error) {
                [promise setError:error];
            }
            else {
                [promise setResult:@(saveOnMainContextSucceeded && saveOnPrivateContextSucceeded)];
            }
        }];
    }];
    
    return [promise future];
}

#pragma mark - Private

- (void)_initializeSQLiteStoreWithDataModelFileName:(NSString *)dataModelFileName callback:(void(^)(void))callback
{
    NSParameterAssert(dataModelFileName);
    
    if ([self mainContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModelFileName withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSAssert(coordinator, @"Failed to initialize coordinator");
    
    [self setMainContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    self.privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.privateContext.persistentStoreCoordinator = coordinator;
    self.mainContext.parentContext = self.privateContext;
    self.slaveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.slaveContext setParentContext:self.mainContext];
    
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
            if (callback)
            {
                callback();
            }
        });
    };
    
    if (callback != nil)
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
