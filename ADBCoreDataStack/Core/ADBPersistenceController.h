//
//  ADBPersistenceController.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ADBPersistenceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADBPersistenceController : NSObject <ADBPersistenceProtocol>

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/**
 *  These methods initialize a Core Data stack. dataModelFileName must be the name of the xcdatamodeld file.
 *  The first version is synchronous and creates the entire stack before returning.
 *  The second one creates the persistent store in background and the callback is called asynchronously.
 *  If the callback parameter is nil, the second method behaves like the first one.
 */
- (id)initWithDataModelFileName:(NSString *)dataModelFileName;
- (id)initWithDataModelFileName:(NSString *)dataModelFileName callback:(void(^__nullable)(void))callback;

@end

NS_ASSUME_NONNULL_END