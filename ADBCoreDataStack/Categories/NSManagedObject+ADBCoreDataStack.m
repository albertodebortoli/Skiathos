//
//  NSManagedObject+ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSManagedObject+ADBCoreDataStack.h"

@implementation NSManagedObject (ADBCoreDataStack)

#pragma mark - Public

- (instancetype)inContext:(NSManagedObjectContext *)otherContext
{
    NSError *error = nil;
    
    if ([[self objectID] isTemporaryID])
    {
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:&error];
        if (!success)
        {
//            [MagicalRecord handleErrors:error];
            return nil;
        }
    }
    
    error = nil;
    
    NSManagedObject *inContext = [otherContext existingObjectWithID:[self objectID] error:&error];
//    [MagicalRecord handleErrors:error];
    
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
    }];
    
    return result;
}

- (void)removeInContext:(NSManagedObjectContext *)context
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
    
    if (!error) {
        for (NSManagedObject *objectToDelete in objectsToDelete) {
            [context deleteObject:objectToDelete];
        }
    }
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error:&error];
    }];
    
    return results;
}

+ (NSArray *)allWithPredicate:(NSPredicate *)pred inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:pred];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error:&error];
    }];
    
    return results;
}

+ (instancetype)firstInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setFetchLimit:1];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error:&error];
    }];
    
    return [results firstObject];
}

+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self adb_basicFetchRequestInContext:context];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setFetchLimit:1];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error;
        results = [context executeFetchRequest:request error:&error];
    }];
    
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

@end
