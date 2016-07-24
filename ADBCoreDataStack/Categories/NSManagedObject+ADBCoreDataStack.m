//
//  NSManagedObject+ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSManagedObject+ADBCoreDataStack.h"

// I don't like this, but I guess we have to make some compromises
#import "ADBJustEatCoreDataStack.h"

@implementation NSManagedObject (ADBCoreDataStack)

#pragma mark - Public

- (instancetype)inContext:(NSManagedObjectContext *)otherContext
{
    NSError *error = nil;
    
    if ([[self objectID] isTemporaryID])
    {
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:&error];
        if (!success) {
            JustPersistenceHandleError(error);
            return nil;
        }
    }
    
    error = nil;
    
    NSManagedObject *inContext = [otherContext existingObjectWithID:[self objectID] error:&error];
    
    if (error) {
        JustPersistenceHandleError(error);
    }
    
    return inContext;
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class)
                                                            inManagedObjectContext:context];
    return mo;
}

+ (NSUInteger)numberOfEntitiesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    
    __block NSUInteger result;
    [context performBlockAndWait:^{
        NSError *error;
        result = [context countForFetchRequest:request error:&error];
        if (error) {
            JustPersistenceHandleError(error);
        }
    }];
    
    return result;
}

+ (NSUInteger)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:searchTerm];
    
    __block NSUInteger result;
    [context performBlockAndWait:^{
        NSError *error;
        result = [context countForFetchRequest:request error:&error];
        if (error) {
            JustPersistenceHandleError(error);
        }
    }];
    
    return result;
}

- (void)deleteInContext:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *objectsToDelete = [context executeFetchRequest:request error:&error];
    
    if (error) {
        JustPersistenceHandleError(error);
    }
    else {
        for (NSManagedObject *objectToDelete in objectsToDelete) {
            [context deleteObject:objectToDelete];
        }
    }
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return results;
}

+ (NSArray *)allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return results;
}

+ (NSArray *)allWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    [request setSortDescriptors:[self adb_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return results;
}

+ (NSArray *)allWhereAttribute:(NSString *)attribute
                     isEqualTo:(NSString *)value
                      sortedBy:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                     inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setSortDescriptors:[self adb_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return results;
}

+ (instancetype)firstInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return [results firstObject];
}

+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return [results firstObject];
}

+ (instancetype)firstWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    [request setSortDescriptors:[self adb_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        JustPersistenceHandleError(error);
    }
    return [results firstObject];
}

#pragma mark - Private

+ (NSFetchRequest *)adb_basicFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:context];
    [request setEntity:entityDescription];
    return request;
}

+ (NSArray *)adb_sortDescriptorsForSortTerm:(NSString *)sortTerm ascending:(BOOL)ascending
{
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    for (__strong NSString *sortKey in sortKeys)
    {
        NSArray * sortComponents = [sortKey componentsSeparatedByString:@":"];
        if (sortComponents.count > 1)
        {
            NSString *customAscending = sortComponents.lastObject;
            ascending = customAscending.boolValue;
            sortKey = sortComponents[0];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    return sortDescriptors;
}

@end
