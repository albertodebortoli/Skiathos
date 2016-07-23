//
//  ADBPersistenceController.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Protocols
#import "ADBPersistenceProtocol.h"

typedef NS_ENUM(NSUInteger, ADBStoreType) {
    ADBStoreTypeSQLite,
    ADBStoreTypeInMemory
};

NS_ASSUME_NONNULL_BEGIN

@interface ADBPersistenceController : NSObject <ADBPersistenceProtocol>

/**
 *  These methods initialize a Core Data stack. dataModelFileName must be the name of the xcdatamodeld file.
 *  The first version is synchronous and creates the entire stack before returning.
 *  The second one creates the persistent store in background and the callback is called asynchronously.
 *  If the callback parameter is nil, the second method behaves like the first one.
 */
- (id)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName;
- (id)initWithStoreType:(ADBStoreType)storeType dataModelFileName:(NSString *)dataModelFileName callback:(void(^__nullable)(void))callback;

@end

NS_ASSUME_NONNULL_END