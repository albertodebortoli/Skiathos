//
//  NSManagedObject+ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSManagedObject+ADBCoreDataStack.h"

// Vendors
#import <JustPromises/JustPromises.h>

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
                                                        inManagedObjectContext:NSManagedObjectContext.child];
    return mo;
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class)
                                                        inManagedObjectContext:context];
    return mo;
}

- (JEFuture *)save
{
    return [[ADBCoreDataStack sharedInstance].DALService saveContext:self.managedObjectContext];
}

- (JEFuture *)remove
{
    return [[ADBCoreDataStack sharedInstance].DALService writeBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        [localContext deleteObject:self];
        
    }];
}

+ (JEFuture *)deleteAll
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    __block NSError *error = nil;
    
    [[ADBCoreDataStack sharedInstance].DALService writeBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NSManagedObjectContext *context = [ADBCoreDataStack sharedInstance].persistenceController.mainContext;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                             inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setReturnsObjectsAsFaults:YES];
        [request setIncludesPropertyValues:NO];
        [request setEntity:entityDescription];
        
        NSArray *objectsToDelete = [localContext executeFetchRequest:request error:&error];
        
        if (!error) {
            for (NSManagedObject *objectToDelete in objectsToDelete) {
                [localContext deleteObject:objectToDelete];
            }
        }
        
    }].continues(^void(JEFuture *fut) {
        
        if (error) {
            [promise setError:error];
        }
        else {
            [promise setResult:@YES];
        }
    });
    
    return [promise future];
}

+ (JEFuture *)all
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:NSManagedObjectContext.main];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [[ADBCoreDataStack sharedInstance].DALService executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError) {
            [promise setError:fut.error];
        }
        else {
            [promise setResult:fut.result];
        }
    });
    
    return [promise future];
}

+ (JEFuture *)allWithPredicate:(NSPredicate *)searchTerm
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:NSManagedObjectContext.main];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:searchTerm];
    
    [[ADBCoreDataStack sharedInstance].DALService executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError) {
            [promise setError:fut.error];
        }
        else {
            [promise setResult:fut.result];
        }
    });
    
    return [promise future];
}

+ (JEFuture *)first
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class)
                                                         inManagedObjectContext:NSManagedObjectContext.main];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchLimit:1];
    
    [[ADBCoreDataStack sharedInstance].DALService executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError) {
            [promise setError:fut.error];
        }
        else {
            NSManagedObject *result = [fut.result firstObject];
            [promise setResult:result];
        }
    });
    
    return [promise future];
}

@end
