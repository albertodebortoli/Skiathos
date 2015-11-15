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
    }
    return self;
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
