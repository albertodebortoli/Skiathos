//
//  ADBCoreDataStackProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol ADBPersistenceProtocol <NSObject>

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *privateContext;
@property (nonatomic, readonly) NSManagedObjectContext *slaveContext;

- (void)save:(void(^)(NSError *error))handler;

@end
