//
//  ADBCoreDataStack.m
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"
#import "ADBAppStateReactor.h"
#import <UIKit/UIKit.h>

@interface ADBCoreDataStack () <ADBAppStateReactorDelegate>

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateContext;
@property (nonatomic, strong, readwrite) ADBAppStateReactor *appStateReactor;

@end

@implementation ADBCoreDataStack

- (instancetype)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName
{
    return [self initWithStoreType:storeType dataModelFileName:dataModelFileName callback:nil];
}

- (instancetype)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName callback:(void(^)(void))callback
{
    self = [super init];
    if (self)
    {
        [self _initializeStoreType:storeType dataModelFileName:dataModelFileName callback:callback];
        _appStateReactor = [[ADBAppStateReactor alloc] init];
        _appStateReactor.delegate = self;
    }
    
    return self;
}

#pragma mark - ADBAppStateReactorDelegate

- (void)appStateReactorDidReceiveStateChange:(ADBAppStateReactor *)reactor
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    return [self save:^(NSError *error) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}


#pragma mark - ADBCoreDataStackProtocol

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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(nil);
            }
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [[self mainContext] performBlock:^{
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSError *mcError = nil;
        BOOL saveOnMainContextSucceeded = [strongSelf.mainContext save:&mcError];
        if (!saveOnMainContextSucceeded)
        {
            NSAssert(saveOnMainContextSucceeded, @"Failed to save main context: %@\n%@", mcError.localizedDescription, mcError.userInfo);
            return;
        }
        
        if (mcError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(mcError);
                }
            });
            return;
        }
        
        [[self privateContext] performBlock:^{
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSError *pcError = nil;
            BOOL saveOnPrivateContextSucceeded = [strongSelf.privateContext save:&pcError];
            
            if (!saveOnPrivateContextSucceeded)
            {
                NSAssert(saveOnPrivateContextSucceeded, @"Error saving private context: %@\n%@", pcError.localizedDescription, pcError.userInfo);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(pcError);
                }
            });
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
