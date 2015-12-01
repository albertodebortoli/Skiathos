//
//  NSManagedObject+ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto DeBortoli on 29/11/2015.
//  Copyright © 2015 JUST EAT. All rights reserved.
//

#import "NSManagedObject+ADBCoreDataStack.h"

// Vendors
#import <JustPromises/JustPromises.h>

// CoreDataStack
#import "ADBGlobals.h"
#import "ADBDALService.h"
#import "ADBPersistenceController.h"

// Categories
#import "NSArray+Functional.h"
#import "NSManagedObject+ADBCoreDataStack.h"
#import "NSObject+Introspecta.h"

@implementation NSManagedObject (ADBCoreDataStack)

#pragma mark - Public

+ (JEFuture *)all
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                         inManagedObjectContext:[ADBGlobals sharedPersistenceController].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [[ADBGlobals sharedDALService] executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError)
        {
            [promise setError:fut.error];
        }
        else
        {
            NSArray *results = [fut result];
            NSArray *pos = [results mapUsingBlock:^id(NSManagedObject *mo) {
                return [mo po];
            }];
            [promise setResult:pos];
        }
    });
    
    return [promise future];
}

+ (JEFuture *)first
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                         inManagedObjectContext:[ADBGlobals sharedPersistenceController].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchLimit:1];
    
    [[ADBGlobals sharedDALService] executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError)
        {
            [promise setError:fut.error];
        }
        else
        {
            NSManagedObject *result = [[fut result] firstObject];
            [promise setResult:[result po]];
        }
    });
    
    return [promise future];
}

+ (JEFuture *)save:(NSArray *)plainObjects
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    [[ADBGlobals sharedDALService] writeBlock:^(NSManagedObjectContext *localContext) {
        
        for (NSObject *plainObject in plainObjects)
        {
            NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:localContext];
            
            [[plainObject cocoaSerialization] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *selecterString = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([mo respondsToSelector:NSSelectorFromString(selecterString)]) {
                    [mo performSelector:NSSelectorFromString(selecterString) withObject:obj];
                }
#pragma clang diagnostic pop
            }];
        }
        
    }].continues(^void(JEFuture *fut) {
        
        [promise setResolutionOfFuture:fut];
    });
    
    return [promise future];
}

+ (JEFuture *)deleteAll
{
    JEPromise *promise = [[JEPromise alloc] init];
    
    __block NSError *error = nil;
    
    [[ADBGlobals sharedDALService] writeBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NSManagedObjectContext *context = [ADBGlobals sharedPersistenceController].managedObjectContext;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class])
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

#pragma mark - Private

- (id)po
{
    return nil;
}

@end
