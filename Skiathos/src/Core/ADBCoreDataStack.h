//
//  ADBCoreDataStack.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADBCoreDataStackProtocol.h"

typedef NS_ENUM(NSUInteger, ADBStoreType) {
    ADBStoreTypeSQLite,
    ADBStoreTypeInMemory
};

NS_ASSUME_NONNULL_BEGIN

@interface ADBCoreDataStack : NSObject <ADBCoreDataStackProtocol>

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 *  These methods initialize the chain of managed object contextes and the persistent store coordinator.
 *  The parameter 'dataModelFileName' must be the name of the xcdatamodeld file.
 *  The first version is synchronous and creates the entire stack before returning.
 *  The second one creates the persistent store in background and the callback is called asynchronously.
 *  If the callback parameter is nil, the second method behaves like the first one.
 */
- (instancetype)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName;
- (instancetype)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName callback:(void(^__nullable)(void))callback;

@end

NS_ASSUME_NONNULL_END