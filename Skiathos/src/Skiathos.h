//
//  Skiathos.h
// 
//
//  Created by Alberto De Bortoli on 20/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#ifndef Skiathos_h
#define Skiathos_h

// Core
#import "ADBCoreDataStack.h"
#import "ADBDALService.h"
#import "ADBAppStateReactor.h"

// Categories
#import "ADBDALService+DotNotation.h"
#import "NSManagedObject+Skiathos.h"

#define HandleDALServiceError(...) [[NSNotificationCenter defaultCenter] postNotificationName:kHandleDALServiceErrorNotification object:self userInfo:@{@"error":__VA_ARGS__}];

@interface Skiathos : ADBDALService

+ (instancetype)sqliteStackWithDataModelFileName:(NSString *)dataModelFileName;
+ (instancetype)inMemoryStackWithDataModelFileName:(NSString *)dataModelFileName;

@end

#endif /* Skiathos_h */
