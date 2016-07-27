//
//  ADBAppStateReactor.m
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBAppStateReactor.h"
#import <UIKit/UIKit.h>

@interface ADBAppStateReactor ()

@property (nonatomic, strong, readwrite) id<ADBCoreDataStackProtocol> coreDataStack;

@end

@implementation ADBAppStateReactor

- (instancetype)initWithCoreDataStack:(id<ADBCoreDataStackProtocol>)coreDataStack
{
    NSParameterAssert(coreDataStack);
    
    self = [super init];
    if (self)
    {
        _coreDataStack = coreDataStack;
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
    [self persist:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self persist:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self persist:nil];
}

- (void)persist:(void(^)(NSError *))handler
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    return [self.coreDataStack save:^(NSError *error) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

@end
