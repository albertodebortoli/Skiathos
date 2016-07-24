//
//  ADBPersistentController.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBPersistentController.h"

@interface ADBPersistentController ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateContext;

@end

@implementation ADBPersistentController

- (id)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName
{
    return [self initWithStoreType:storeType dataModelFileName:dataModelFileName callback:nil];
}

- (id)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName callback:(void(^)(void))callback
{
    self = [super init];
    if (self)
    {
        [self _initializeStoreType:storeType dataModelFileName:dataModelFileName callback:callback];
    }
    
    return self;
}

#pragma mark - ADBPersistenceProtocol

- (void)save:(void(^)(NSError *error))handler;
{
    __block BOOL mainHasChanges = NO;
    __block BOOL privateHasChanges = NO;
    
    [self.mainContext performBlockAndWait:^{
        mainHasChanges = [self.mainContext hasChanges];
    }];
    
    [self.privateContext performBlockAndWait:^{
        privateHasChanges = [self.privateContext hasChanges];
    }];
    
    if (!mainHasChanges && !privateHasChanges) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [[self mainContext] performBlock:^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSError *mcError = nil;
        BOOL saveOnMainContextSucceeded = [strongSelf.mainContext save:&mcError];
        NSAssert(saveOnMainContextSucceeded, @"Failed to save main context: %@\n%@", mcError.localizedDescription, mcError.userInfo);
        
        if (mcError) {
            if (handler) {
                handler(mcError);
            }
            return;
        }
        
        [[self privateContext] performBlock:^{
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSError *pcError = nil;
            BOOL saveOnPrivateContextSucceeded = [strongSelf.privateContext save:&pcError];
            NSAssert(saveOnPrivateContextSucceeded, @"Error saving private context: %@\n%@", pcError.localizedDescription, pcError.userInfo);

            if (pcError) {
                if (handler) {
                    handler(pcError);
                }
            }
        }];
    }];
}

#pragma mark - Private

- (void)_initializeStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName callback:(void(^)(void))callback
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
    
    void (^privateContextSetupBlock)() = ^{
        NSPersistentStoreCoordinator *psc = [[self privateContext] persistentStoreCoordinator];
        
        switch (storeType) {
            case ADBStoreTypeSQLite:
                [[self class] adb_addSQLiteStoreToCoordinator:psc dataModelFileName:dataModelFileName];
                break;
            case ADBStoreTypeInMemory:
                [[self class] adb_addInMemoryStoreToCoordinator:psc];
                break;
        }
        
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

#pragma mark - Private

+ (void)adb_addSQLiteStoreToCoordinator:(NSPersistentStoreCoordinator *)psc dataModelFileName:(NSString *)dataModelFileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", dataModelFileName]];
    NSDictionary *options = [self adb_autoMigratingOptions];
    
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:options
                                                         error:&error];
    if (!store)
    {
        // handle error @"Error adding Persistent Store: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

+ (void)adb_addInMemoryStoreToCoordinator:(NSPersistentStoreCoordinator *)psc
{
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSInMemoryStoreType
                                                 configuration:nil
                                                           URL:nil
                                                       options:nil
                                                         error:&error];
    if (!store)
    {
        // handle error @"Error adding Persistent Store: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

+ (NSDictionary *)adb_autoMigratingOptions;
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
    options[NSInferMappingModelAutomaticallyOption] = @YES;
    options[NSSQLitePragmasOption] = @{ @"journal_mode":@"WAL" };
    
    return options;
}

@end
