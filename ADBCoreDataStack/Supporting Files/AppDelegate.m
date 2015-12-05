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

// Plain Objects
#import "UserPO.h"

// Vendors
#import <JustPromises/JustPromises.h>

// CoreDataStack
#import "ADBGlobals.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[ADBGlobals sharedCoreDataStack] initialize];
    [self showMeSomething];
    
    return YES;
}

- (void)showMeSomething
{
    NSLog(@"Delete all");
    [User deleteAll].continueWithSuccessTask(^JEFuture *(NSNumber *result) {
        return [User all].continueWithSuccessTask(^JEFuture *(NSArray *allUsers) {
            NSLog(@"All users: %@", allUsers);
            return [JEFuture futureWithResult:allUsers];
        });
    }).continueWithSuccessTask(^JEFuture *(NSNumber *result) {
        UserPO *userPO = [UserPO userWithBlock:^(UserPOBuilder *builder) {
            builder.firstname = @"John";
            builder.lastname = @"Doe";
        }];
        NSLog(@"Save one");
        return [User save:@[userPO]];
    }).continueWithSuccessTask(^JEFuture *(NSNumber *result) {
        return [User first].continueWithSuccessTask(^JEFuture *(UserPO *userPO) {
            NSLog(@"Fetch one");
            NSLog(@"%@ %@", userPO.firstname, userPO.lastname);
            return [JEFuture futureWithResult:userPO];
        });
    }).continues(^(JEFuture *fut) {
        [User all].continueOnMainQueue(^(JEFuture *fut) {
            NSArray *allUsers = [fut result];
            NSLog(@"All users: %@", allUsers);
        });
    });
}

@end
