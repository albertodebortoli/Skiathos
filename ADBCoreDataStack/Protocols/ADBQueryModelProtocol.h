//
//  ADBQueryModelProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBQueryModelProtocol <NSObject>

// Readings

- (NSArray *)objectsFetchRequest:(NSFetchRequest *)fetchRequest;
- (NSManagedObject *)objectFetchRequest:(NSFetchRequest *)fetchRequest;

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request;

@end

NS_ASSUME_NONNULL_END
