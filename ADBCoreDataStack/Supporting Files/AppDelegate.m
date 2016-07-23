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
    
    [User deleteAll];
    
    NSArray *allUsers = [User all];
    NSLog(@"All users: %@", allUsers);
    
    User *user = [User create];
    user.firstname = @"John";
    user.lastname = @"Doe";
    
    NSLog(@"Count: %li", [User numberOfEntities]);
    
    NSLog(@"Save one");
    [user save];
    
    User *user2 = [User first];
    NSLog(@"Fetch one");
    NSLog(@"%@ %@", user2.firstname, user2.lastname);
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", @"firstname", @"John"];
    NSLog(@"Count: %li", [User numberOfEntitiesWithPredicate:pred]);

    NSArray *allUsers2 = [User all];
    NSLog(@"All users: %@", allUsers2);
    
}

@end
