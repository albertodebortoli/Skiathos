//
//  ADBCommandModelProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBCommandModelProtocol <NSObject>

// Writings

- (void)saveContext:(NSManagedObjectContext *)context;
- (void)saveToPersistentStore;
- (void)writeBlock:(void(^)(NSManagedObjectContext *))changes;

@end

NS_ASSUME_NONNULL_END