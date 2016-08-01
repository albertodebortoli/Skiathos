//
//  SkiathosTests.m
// 
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Skiathos.h"
#import "ADBDALService+DotNotation.h"
#import "User.h"

#define kUnitTestTimeout (10.0)

@interface SkiathosTests : XCTestCase

@property (nonatomic, strong) Skiathos *skiathos;

@end

@implementation SkiathosTests

- (void)setUp
{
    [super setUp];
    self.skiathos = [Skiathos inMemoryStackWithDataModelFileName:@"DataModel"];
}

- (void)tearDown
{
    self.skiathos = nil;
    [super tearDown];
}

- (void)test_Chaining
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    [[[self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        user = [User SK_createInContext:context];
        user = [user SK_inContext:context];
        [User SK_createInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
    }] write:^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user SK_inContext:context];
        [userInContext SK_deleteInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
    }] read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_ChainingDotNotation
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    self.skiathos.write(^(NSManagedObjectContext * _Nonnull context) {
        user = [User SK_createInContext:context];
        user = [user SK_inContext:context];
        [User SK_createInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
    }).write(^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user SK_inContext:context];
        [userInContext SK_deleteInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
    }).read(^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DispatchAyncOnMainQueue
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.skiathos.write(^(NSManagedObjectContext *context) {
            [User SK_deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).write(^(NSManagedObjectContext *context) {
            User *user = [User SK_createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 1);
            [expectation fulfill];
        });
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DispatchAyncOnBackgroundQueue
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        
        self.skiathos.write(^(NSManagedObjectContext *context) {
            [User SK_deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).write(^(NSManagedObjectContext *context) {
            User *user = [User SK_createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 1);
            [expectation fulfill];
        });
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_performance
{
    [self measureBlock:^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        __block NSInteger count = 3;
        
        while (count)
        {
            dispatch_semaphore_wait(sem, DISPATCH_TIME_NOW);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            
            [self.skiathos.write(^(NSManagedObjectContext *context) {
                User *user = [User SK_createInContext:context];
                user.firstname = @"John";
                user.lastname = @"Doe";
            }).write(^(NSManagedObjectContext *context) {
                [User SK_deleteAllInContext:context];
            }) write:^(NSManagedObjectContext *context) {
                [User SK_allInContext:context];
            } completion:^(NSError * _Nullable error) {
                count--;
                dispatch_semaphore_signal(sem);
            }];
        }
    }];
}

@end
