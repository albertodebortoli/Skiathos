//
//  ViewController.m
//
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ViewController.h"

#import "SkiathosClient.h"
#import "User.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    while (YES)
    {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_NOW);
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        
        [[SkiathosClient sharedInstance].write(^(NSManagedObjectContext *context) {
            User *user = [User createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }).write(^(NSManagedObjectContext *context) {
            [User deleteAllInContext:context];
        }) write:^(NSManagedObjectContext *context) {
            [User allInContext:context];
        } completion:^(NSError * _Nullable error) {
            dispatch_semaphore_signal(sem);
        }];
    }
}

@end
