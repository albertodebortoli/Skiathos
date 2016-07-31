//
//  NSManagedObject+Skiathos.h
//
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Skiathos)

- (instancetype)SK_inContext:(NSManagedObjectContext *)otherContext;
+ (instancetype)SK_createInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)SK_numberOfEntitiesInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)SK_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
- (void)SK_deleteInContext:(NSManagedObjectContext *)context;
+ (void)SK_deleteAllInContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)SK_allInContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)SK_allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)SK_allWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSArray <__kindof NSManagedObject *> *)SK_allWhereAttribute:(NSString *)attribute
                                                     isEqualTo:(NSString *)value
                                                      sortedBy:(NSString *)sortTerm
                                                     ascending:(BOOL)ascending
                                                     inContext:(NSManagedObjectContext *)context;
+ (instancetype)SK_firstInContext:(NSManagedObjectContext *)context;
+ (instancetype)SK_firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context;
+ (instancetype)SK_firstWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

@end
