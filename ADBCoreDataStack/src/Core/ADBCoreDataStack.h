//
//  ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBPersistenceProtocol.h"
#import "ADBDALProtocol.h"

static NSString *const kCoreDataStackHandleErrorNotification = @"kCoreDataStackHandleErrorNotification";

#define CoreDataStackHandleError(...) [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataStackHandleErrorNotification object:self userInfo:@{@"error":__VA_ARGS__}];

@interface ADBCoreDataStack : NSObject

@property (nonatomic, readonly) id <ADBPersistenceProtocol> persistenceController;
@property (nonatomic, readonly) id <ADBDALProtocol> DALService;

- (instancetype)initWithPersistenceController:(id <ADBPersistenceProtocol>)persistenceController
                                   dalService:(id <ADBDALProtocol>)dalService;

- (void)handleError:(NSError *)error;

@end
