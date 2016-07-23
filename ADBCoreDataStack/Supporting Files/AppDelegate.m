//
//  AppDelegate.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "AppDelegate.h"

// Categories
#import "NSManagedObject+ADBCoreDataStack.h"

// Managed Objects
#import "User.h"
#import "Pet.h"

// CoreDataStack
#import "ADBJustEatCoreDataStack.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // to initialize the stack
    [ADBJustEatCoreDataStack sharedInstance];
    [self showMeSomethingFromMainQueueStraight];
    [self showMeSomethingFromMainQueueStraight];
    [self showMeSomethingFromMainQueueStraight];
//    [self showMeSomethingFromMainQueue];
//    [self showMeSomethingFromMainQueue];
//    [self showMeSomethingFromMainQueue];
    [self showMeSomethingFromBkgQueue];
    [self showMeSomethingFromBkgQueue];
    [self showMeSomethingFromBkgQueue];
    
    return YES;
}

- (void)showMeSomethingFromMainQueueStraight
{
    [JustPersistence write:^(NSManagedObjectContext *context) {
        NSLog(@"Delete all");
        [User deleteAllInContext:context];
    }];
    
    [JustPersistence read:^(NSManagedObjectContext *context) {
        NSArray *allUsers = [User allInContext:context];
        NSLog(@"All users: %@", allUsers);
    }];
    
    [JustPersistence write:^(NSManagedObjectContext *context) {
        User *user = [User createInContext:context];
        user.firstname = @"John";
        user.lastname = @"Doe";
    }];
    
    [JustPersistence read:^(NSManagedObjectContext *context) {
        NSLog(@"Count: %li", [User numberOfEntitiesInContext:context]);
        
        NSLog(@"Fetch one");
        User *user2 = [User firstInContext:context];
        NSLog(@"%@ %@", user2.firstname, user2.lastname);
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", @"firstname", @"John"];
        NSLog(@"Count: %li", [User numberOfEntitiesWithPredicate:pred inContext:context]);
        
        NSArray *allUsers2 = [User allInContext:context];
        NSLog(@"All users: %@", allUsers2);
    }];
    
}

- (void)showMeSomethingFromMainQueue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [JustPersistence write:^(NSManagedObjectContext *context) {
            NSLog(@"Delete all");
            [User deleteAllInContext:context];
        }];
        
        [JustPersistence read:^(NSManagedObjectContext *context) {
            NSArray *allUsers = [User allInContext:context];
            NSLog(@"All users: %@", allUsers);
        }];
    
        [JustPersistence write:^(NSManagedObjectContext *context) {
            User *user = [User createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }];
        
        [JustPersistence read:^(NSManagedObjectContext *context) {
            NSLog(@"Count: %li", [User numberOfEntitiesInContext:context]);
        
            NSLog(@"Fetch one");
            User *user2 = [User firstInContext:context];
            NSLog(@"%@ %@", user2.firstname, user2.lastname);
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", @"firstname", @"John"];
            NSLog(@"Count: %li", [User numberOfEntitiesWithPredicate:pred inContext:context]);
            
            NSArray *allUsers2 = [User allInContext:context];
            NSLog(@"All users: %@", allUsers2);
        }];
        
    });
}

- (void)showMeSomethingFromBkgQueue
{
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        
        [JustPersistence write:^(NSManagedObjectContext *context) {
            NSLog(@"Delete all");
            [User deleteAllInContext:context];
        }];
        
        [JustPersistence read:^(NSManagedObjectContext *context) {
            NSArray *allUsers = [User allInContext:context];
            NSLog(@"All users: %@", allUsers);
        }];
        
        [JustPersistence write:^(NSManagedObjectContext *context) {
            User *user = [User createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }];
        
        [JustPersistence read:^(NSManagedObjectContext *context) {
            NSLog(@"Count: %li", [User numberOfEntitiesInContext:context]);
        
            NSLog(@"Fetch one");
            User *user2 = [User firstInContext:context];
            NSLog(@"%@ %@", user2.firstname, user2.lastname);
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", @"firstname", @"John"];
            NSLog(@"Count: %li", [User numberOfEntitiesWithPredicate:pred inContext:context]);
            
            NSArray *allUsers2 = [User allInContext:context];
            NSLog(@"All users: %@", allUsers2);
        }];
        
    });
}

@end
