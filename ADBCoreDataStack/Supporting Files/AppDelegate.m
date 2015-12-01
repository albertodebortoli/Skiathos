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
    [User deleteAll].continues(^void(JEFuture *fut) {

        [User all].continueOnMainQueue(^(JEFuture *fut) {
            NSArray *allUsers = [fut result];
            NSLog(@"%@", allUsers);
        });

    });

    [User all].continueOnMainQueue(^(JEFuture *fut) {
        NSArray *allUsers = [fut result];
        NSLog(@"%@", allUsers);
    });


    [[ADBGlobals sharedCoreDataStack] initialize];
    
    UserPO *userPO = [UserPO userWithBlock:^(UserPOBuilder *builder) {
        builder.firstname = @"Alberto";
        builder.lastname = @"De Bo";
    }];

    [User save:@[userPO]].continueWithTask(^JEFuture *(JEFuture *fut) {

        if ([fut hasResult])
        {
            [User first].continueOnMainQueue(^(JEFuture *fut) {
                UserPO *userPO = fut.result;
                NSLog(@"%@ %@", userPO.firstname, userPO.lastname);
            });
        }
    
        return [JEFuture futureWithResolutionOfFuture:fut];
    });
    
    [User all].continueOnMainQueue(^(JEFuture *fut) {
        NSArray *allUsers = [fut result];
        NSLog(@"%@", allUsers);
    });
    
    return YES;
}

@end
