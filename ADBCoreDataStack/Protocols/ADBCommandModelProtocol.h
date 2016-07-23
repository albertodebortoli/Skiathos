//
//  ADBCommandModelProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <JustPromises/JustPromises.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBCommandModelProtocol <NSObject>

- (NSManagedObjectContext *)slaveContext;

// Writings

- (JEFuture *)saveContext:(NSManagedObjectContext *)context;
- (JEFuture *)saveToPersistentStore;
- (JEFuture *)writeBlock:(void(^)(NSManagedObjectContext *localContext))changes;

@end

NS_ASSUME_NONNULL_END