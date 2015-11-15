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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[ADBCoreDataStackClient sharedInstance] persist];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ADBCoreDataStackClient sharedInstance] persist];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[ADBCoreDataStackClient sharedInstance] persist];
}

@end
