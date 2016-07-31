//
//  NSManagedObject+Skiathos.m
// 
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSManagedObject+Skiathos.h"
#import "ADBDALService.h"

@implementation NSManagedObject (Skiathos)

#pragma mark - Public

- (instancetype)SK_inContext:(NSManagedObjectContext *)otherContext
{
    NSError *error = nil;
    
    if ([[self objectID] isTemporaryID])
    {
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:&error];
        if (!success) {
            HandleDALServiceError(error);
            return nil;
        }
    }
    
    error = nil;
    
    NSManagedObject *inContext = [otherContext existingObjectWithID:[self objectID] error:&error];
    
    if (error) {
        HandleDALServiceError(error);
    }
    
    return inContext;
}

+ (instancetype)SK_createInContext:(NSManagedObjectContext *)context
{
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class)
                                                            inManagedObjectContext:context];
    return mo;
}

+ (NSUInteger)SK_numberOfEntitiesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    
    NSError *error;
    NSUInteger result = [context countForFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    
    return result;
}

+ (NSUInteger)SK_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:searchTerm];
    
    NSError *error;
    NSUInteger result = [context countForFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    
    return result;
}

- (void)SK_deleteInContext:(NSManagedObjectContext *)context
{
    [context deleteObject:self];
}

+ (void)SK_deleteAllInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *objectsToDelete = [context executeFetchRequest:request error:&error];
    
    if (error) {
        HandleDALServiceError(error);
    }
    else {
        for (NSManagedObject *objectToDelete in objectsToDelete) {
            [context deleteObject:objectToDelete];
        }
    }
}

+ (NSArray *)SK_allInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return results;
}

+ (NSArray *)SK_allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return results;
}

+ (NSArray *)SK_allWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    [request setSortDescriptors:[self SK_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return results;
}

+ (NSArray *)SK_allWhereAttribute:(NSString *)attribute
                     isEqualTo:(NSString *)value
                      sortedBy:(NSString *)sortTerm
                     ascending:(BOOL)ascending
                     inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setSortDescriptors:[self SK_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return results;
}

+ (instancetype)SK_firstInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return [results firstObject];
}

+ (instancetype)SK_firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return [results firstObject];
}

+ (instancetype)SK_firstWithPredicate:(NSPredicate *)pred sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self SK_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    [request setFetchLimit:1];
    [request setFetchBatchSize:1];
    [request setSortDescriptors:[self SK_sortDescriptorsForSortTerm:sortTerm ascending:ascending]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) {
        HandleDALServiceError(error);
    }
    return [results firstObject];
}

#pragma mark - Private

+ (NSFetchRequest *)SK_basicFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:context];
    [request setEntity:entityDescription];
    return request;
}

+ (NSArray <__kindof NSSortDescriptor *> *)SK_sortDescriptorsForSortTerm:(NSString *)sortTerms ascending:(BOOL)ascending
{
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    NSArray *sortKeys = [sortTerms componentsSeparatedByString:@","];
    for (__strong NSString *sortKey in sortKeys)
    {
        NSArray <NSString *> *sortComponents = [sortKey componentsSeparatedByString:@":"];
        BOOL customAscending = ascending;
        if (sortComponents.count > 1)
        {
            customAscending = sortComponents.lastObject.boolValue;
            sortKey = sortComponents[0];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:customAscending];
        [sortDescriptors addObject:sortDescriptor];
    }
    return sortDescriptors;
}

@end
