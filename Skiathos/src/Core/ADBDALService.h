//
//  ADBDALService.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBCoreDataStackProtocol.h"
#import "ADBDALProtocol.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kHandleDALServiceErrorNotification = @"kHandleDALServiceErrorNotification";

#define HandleDALServiceError(...) [[NSNotificationCenter defaultCenter] postNotificationName:kHandleDALServiceErrorNotification object:self userInfo:@{@"error":__VA_ARGS__}];

@interface ADBDALService : NSObject <ADBDALProtocol>

- (instancetype)initWithCoreDataStack:(id<ADBCoreDataStackProtocol>)coreDataStack;

@end

NS_ASSUME_NONNULL_END
