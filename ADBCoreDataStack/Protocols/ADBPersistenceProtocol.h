//
//  ADBCoreDataStackProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Vendors
#import <JustPromises/JustPromises.h>

@protocol ADBPersistenceProtocol <NSObject>

- (NSManagedObjectContext *)managedObjectContext;

- (JEFuture *)save;

@end
