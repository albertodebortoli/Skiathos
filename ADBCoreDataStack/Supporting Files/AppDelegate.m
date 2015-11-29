//
//  AppDelegate.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "AppDelegate.h"

// Managed Objects
#import "User.h"
#import "Pet.h"

// Plain Objects
#import "UserPO.h"

// Vendors
#import <JustPromises/JustPromises.h>

// CoreDataStack
#import "ADBCoreDataStack+User.h"
#import "ADBCoreDataStackClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UserPO *userPO = [UserPO userWithBlock:^(UserPOBuilder *builder) {
        builder.firstname = @"Alberto";
    }];

    [[ADBCoreDataStackClient sharedInstance] saveUser:userPO].continueWithTask(^JEFuture *(JEFuture *fut) {
        
        if ([fut hasResult])
        {
            UserPO *userPO = [[ADBCoreDataStackClient sharedInstance] currentUser];
            NSLog(@"%@ %@", userPO.firstname, userPO.lastname);
        }
        
        return [JEFuture futureWithResolutionOfFuture:fut];
    });
    
    NSArray *allUsers = [[ADBCoreDataStackClient sharedInstance] allUsers];
    
    NSLog(@"%@", allUsers);
    
    return YES;
}

@end
