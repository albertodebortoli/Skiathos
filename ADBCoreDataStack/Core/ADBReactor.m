//
//  ADBReactor.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBReactor.h"

// Frameworks
#import <UIKit/UIKit.h>

@interface ADBReactor ()

@property (nonatomic, strong, readwrite) id<ADBPersistenceProtocol> persistenceController;

@end

@implementation ADBReactor

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)initialize
{
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

- (JEFuture *)persist
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    return [self.persistenceController save].continueWithTask(^JEFuture *(JEFuture *fut) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        return [JEFuture futureWithResolutionOfFuture:fut];
    });
}

@end
