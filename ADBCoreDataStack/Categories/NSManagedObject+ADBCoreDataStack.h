//
//  NSManagedObject+ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ADBCoreDataStack)

- (instancetype)inContext:(NSManagedObjectContext *)otherContext;
+ (instancetype)createInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)numberOfEntitiesInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
- (void)deleteInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context;
+ (NSArray *)allWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSArray *)allWhereAttribute:(NSString *)attribute
                     isEqualTo:(NSString *)value
                      sortedBy:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                     inContext:(NSManagedObjectContext *)context;
+ (instancetype)firstInContext:(NSManagedObjectContext *)context;
+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context;
+ (instancetype)firstWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

@end
