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

+ (NSUInteger)numberOfEntities; // main context
+ (NSUInteger)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm; // main context

- (void)save; // from object's context down to disk
- (void)remove; // down to disk
+ (void)deleteAll; // down to disk

// Readings
+ (NSArray *)all; // main context
+ (NSArray *)allWithPredicate:(NSPredicate *)pred; // main context
+ (instancetype)first; // main context
+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value;

@end
