//
//  ADBDataAccessLayerProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <JustPromises/JustPromises.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBDataAccessLayerProtocol <NSObject>

- (NSManagedObjectContext *)mainContext;

// Readings

- (JEFuture *)executeFetchRequest:(NSFetchRequest *)request;
- (JEFuture *)countForFetchRequest:(NSFetchRequest *)request;

// Writings

- (JEFuture *)writeBlock:(void(^)(NSManagedObjectContext *localContext))changes;

@end

NS_ASSUME_NONNULL_END