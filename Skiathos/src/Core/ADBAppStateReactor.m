//
//  ADBAppStateReactor.m
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBAppStateReactor.h"
#import <UIKit/UIKit.h>

@implementation ADBAppStateReactor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
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
    [self _forwardStatusChange];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self _forwardStatusChange];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self _forwardStatusChange];
}

- (void)_forwardStatusChange
{
    [self.delegate appStateReactorDidReceiveStateChange:self];
}

@end
