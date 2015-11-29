//
//  ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"
#import <UIKit/UIKit.h>

@interface ADBCoreDataStack ()

@property (nonatomic, strong, readwrite) id<ADBDataAccessLayerProtocol> DALService;
@property (nonatomic, strong, readwrite) id<ADBPersistenceProtocol> persistenceController;

@end

@implementation ADBCoreDataStack

- (instancetype)initWithDALService:(id<ADBDataAccessLayerProtocol>)DALService
             persistenceController:(id<ADBPersistenceProtocol>)persistenceController;
{
    NSParameterAssert(DALService);
    NSParameterAssert(persistenceController);
    
    self = [super init];
    if (self)
    {
        _DALService = DALService;
        _persistenceController = persistenceController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self persist];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self persist];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self persist];
}

- (void)persist
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self.persistenceController save:^(NSError *error) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

@end
