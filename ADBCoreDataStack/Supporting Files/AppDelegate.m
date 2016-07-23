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
#import "NSManagedObjectContext+JEAdditions.h"

// Managed Objects
#import "User.h"
#import "Pet.h"

// Plain Objects
//#import "UserPO.h"

// Vendors
#import <JustPromises/JustPromises.h>

// CoreDataStack
#import "ADBCoreDataStack.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // to initialize the stack
    [ADBCoreDataStack sharedInstance];
    [self showMeSomething];
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
        
        User *user = [User create];
        user.firstname = @"John";
        user.lastname = @"Doe";
        
        NSLog(@"Save one");
        return [user save];
        
    }).continueWithSuccessTask(^JEFuture *(NSNumber *result) {
        return [User first].continueWithSuccessTask(^JEFuture *(User *user) {
            NSLog(@"Fetch one");
//            NSLog(@"%@ %@", user.firstname, user.lastname);
            return [JEFuture futureWithResult:user];
        });
    }).continues(^(JEFuture *fut) {
        [User all].continueOnMainQueue(^(JEFuture *fut) {
            NSArray *allUsers = [fut result];
            NSLog(@"All users: %@", allUsers);
        });
    });
}

@end
