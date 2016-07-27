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

static NSString *const kSkiathosHandleErrorNotification = @"kSkiathosHandleErrorNotification";

#define SkiathosHandleError(...) [[NSNotificationCenter defaultCenter] postNotificationName:kSkiathosHandleErrorNotification object:self userInfo:@{@"error":__VA_ARGS__}];

@interface ADBDALService : NSObject <ADBDALProtocol>

- (instancetype)initWithCoreDataStack:(id<ADBCoreDataStackProtocol>)coreDataStack;

@end

NS_ASSUME_NONNULL_END
