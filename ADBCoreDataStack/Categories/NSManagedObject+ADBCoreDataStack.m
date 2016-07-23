//
//  NSManagedObject+ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSManagedObject+ADBCoreDataStack.h"

// CoreDataStack
#import "ADBCoreDataStack.h"
#import "ADBDALService.h"
#import "ADBPersistenceController.h"

// Categories
#import "NSArray+Functional.h"
#import "NSManagedObjectContext+JEAdditions.h"

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

+ (instancetype)create
{
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class)
                                                        inManagedObjectContext:NSManagedObjectContext.main];
    return mo;
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class)
                                                        inManagedObjectContext:context];
    return mo;
}

+ (NSUInteger)numberOfEntities
{
    NSFetchRequest *request = [self basicFetchRequest];
    return [[ADBCoreDataStack sharedInstance].DALService countForFetchRequest:request];
}

+ (NSUInteger)numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm
{
    NSFetchRequest *request = [self basicFetchRequest];
    [request setPredicate:searchTerm];
    return [[ADBCoreDataStack sharedInstance].DALService countForFetchRequest:request];
}

- (void)save
{
    [[ADBCoreDataStack sharedInstance].DALService saveContext:self.managedObjectContext];
}

- (void)remove
{
    [[ADBCoreDataStack sharedInstance].DALService writeBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [localContext deleteObject:self];
    }];
}

+ (void)deleteAll
{
    [[ADBCoreDataStack sharedInstance].DALService writeBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                
        NSFetchRequest *request = [self basicFetchRequest];
        [request setReturnsObjectsAsFaults:YES];
        [request setIncludesPropertyValues:NO];
        
        NSError *error = nil;
        NSArray *objectsToDelete = [localContext executeFetchRequest:request error:&error];
        
        if (!error) {
            for (NSManagedObject *objectToDelete in objectsToDelete) {
                [localContext deleteObject:objectToDelete];
            }
        }
        
    }];
}

+ (NSArray *)all
{
    NSFetchRequest *request = [self basicFetchRequest];
    return [self adb_objectsForFetchRequest:request];
}

+ (NSArray *)allWithPredicate:(NSPredicate *)pred
{
    NSFetchRequest *request = [self basicFetchRequest];
    [request setPredicate:pred];
    
    return [self adb_objectsForFetchRequest:request];
}

+ (instancetype)first
{
    NSFetchRequest *request = [self basicFetchRequest];
    [request setFetchLimit:1];
    
    return [self adb_firstObjectForFetchRequest:request];
}

+ (instancetype)firstWhereAttribute:(NSString *)attribute isEqualTo:(NSString *)value
{
    NSFetchRequest *request = [self basicFetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, value]];
    [request setFetchLimit:1];
    
    return [self adb_firstObjectForFetchRequest:request];
}

#pragma mark - Private

+ (NSFetchRequest *)basicFetchRequest
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:NSManagedObjectContext.main];
    [request setEntity:entityDescription];
    return request;
}

+ (NSArray *)adb_objectsForFetchRequest:(NSFetchRequest *)request
{
    NSArray *results = [[ADBCoreDataStack sharedInstance].DALService objectsFetchRequest:request];
    return results;
}

+ (NSManagedObject *)adb_firstObjectForFetchRequest:(NSFetchRequest *)request
{
    NSManagedObject *object = [[ADBCoreDataStack sharedInstance].DALService objectFetchRequest:request];
    return object;
}

@end
