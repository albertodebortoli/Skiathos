//
//  NSManagedObject+ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import <CoreData/CoreData.h>

// Vendors
#import <JustPromises/JustPromises.h>

@interface NSManagedObject (ADBCoreDataStack)

// Writings
+ (instancetype)create;
+ (instancetype)createInContext:(NSManagedObjectContext *)context;

- (JEFuture *)save; // from object's context down to disk
- (JEFuture *)remove; // down to disk
+ (JEFuture *)deleteAll; // down to disk

// Readings
+ (JEFuture *)all; // main context
+ (JEFuture *)first; // main context

@end
