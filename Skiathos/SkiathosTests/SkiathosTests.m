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
    self.skiathos = [Skiathos setupInMemoryStackWithDataModelFileName:@"DataModel"];
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
    
    [[[self.skiathos writeSync:^(NSManagedObjectContext * _Nonnull context) {
        user = [User SK_createInContext:context];
        user = [user SK_inContext:context];
        [User SK_createInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
    }] writeSync:^(NSManagedObjectContext * _Nonnull context) {
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
    
    self.skiathos.writeSync(^(NSManagedObjectContext * _Nonnull context) {
        user = [User SK_createInContext:context];
        user = [user SK_inContext:context];
        [User SK_createInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
    }).writeSync(^(NSManagedObjectContext * _Nonnull context) {
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
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            [User SK_deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).writeSync(^(NSManagedObjectContext *context) {
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
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            [User SK_deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User SK_allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).writeSync(^(NSManagedObjectContext *context) {
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
            
            [self.skiathos.writeSync(^(NSManagedObjectContext *context) {
                User *user = [User SK_createInContext:context];
                user.firstname = @"John";
                user.lastname = @"Doe";
            }).writeSync(^(NSManagedObjectContext *context) {
                [User SK_deleteAllInContext:context];
            }) writeSync:^(NSManagedObjectContext *context) {
                [User SK_allInContext:context];
            } completion:^(NSError * _Nullable error) {
                count--;
                dispatch_semaphore_signal(sem);
            }];
        }
    }];
}

- (void)test_CorrectOrderOfOperationsMainQueue_SyncWrites
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block NSUInteger counter = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        XCTAssertEqual(counter, 0);
        counter++;
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 1);
            counter++;
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 2);
            counter++;
        }).writeSync(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 3);
            counter++;
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 4);
            counter++;
        });
        
        XCTAssertEqual(counter, 5);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_CorrectOrderOfOperationsBkgQueue_SyncWrites
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block NSUInteger counter = 0;
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        
        XCTAssertEqual(counter, 0);
        counter++;
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 1);
            counter++;
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 2);
            counter++;
        }).writeSync(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 3);
            counter++;
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertEqual(counter, 4);
            counter++;
        });
        
        XCTAssertEqual(counter, 5);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_CorrectThreadingOfOperationsMainQueue_SyncWrite
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            XCTAssertTrue([NSThread isMainThread]);
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertTrue([NSThread isMainThread]);
            [expectation fulfill];
        });
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_CorrectThreadingOfOperationsBkgQueue_SyncWrite
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        
        self.skiathos.writeSync(^(NSManagedObjectContext *context) {
            XCTAssertFalse([NSThread isMainThread]);
        }).read(^(NSManagedObjectContext *context) {
            XCTAssertTrue([NSThread isMainThread]);
            [expectation fulfill];
        });
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_CorrectThreadingOfOperationsMainQueue_AsyncWrite
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.skiathos writeAsync:^(NSManagedObjectContext * _Nonnull context) {
            XCTAssertFalse([NSThread isMainThread]);
        } completion:^(NSError * _Nullable error) {
            XCTAssertTrue([NSThread isMainThread]);
            [expectation fulfill];
        }];
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_CorrectThreadingOfOperationsBkgQueue_AsyncWrite
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        
        [self.skiathos writeAsync:^(NSManagedObjectContext * _Nonnull context) {
            XCTAssertFalse([NSThread isMainThread]);
        } completion:^(NSError * _Nullable error) {
            XCTAssertTrue([NSThread isMainThread]);
            [expectation fulfill];
        }];
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

@end
