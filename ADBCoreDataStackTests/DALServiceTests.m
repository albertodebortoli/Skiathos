//
//  DALServiceTests.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ADBPersistence.h"
#import "ADBDALService+DotNotation.h"
#import "User.h"

#define kUnitTestTimeout (10.0)

@interface DALServiceTests : XCTestCase

@property (nonatomic, strong) ADBCoreDataStack *stack;

@end

@implementation DALServiceTests

- (void)setUp
{
    [super setUp];
    self.stack = [ADBCoreDataStack inMemoryCoreDataStackWithDataModelFileName:@"DataModel"];
}

- (void)tearDown
{
    self.stack = nil;
    [super tearDown];
}

- (void)test_Chaining
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    [[[self.stack.DALService write:^(NSManagedObjectContext * _Nonnull context) {
        user = [User createInContext:context];
        user = [user inContext:context];
        [User createInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
    }] write:^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user inContext:context];
        [userInContext deleteInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
    }] read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_ChainingDotNotation
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    self.stack.DALService.write(^(NSManagedObjectContext * _Nonnull context) {
        user = [User createInContext:context];
        user = [user inContext:context];
        [User createInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 2);
    }).write(^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user inContext:context];
        [userInContext deleteInContext:context];
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
    }).read(^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DispatchAyncOnMainQueue
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stack.DALService.write(^(NSManagedObjectContext *context) {
            [User deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).write(^(NSManagedObjectContext *context) {
            User *user = [User createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User allInContext:context];
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
        
        self.stack.DALService.write(^(NSManagedObjectContext *context) {
            [User deleteAllInContext:context];
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User allInContext:context];
            XCTAssertEqual(users.count, 0);
        }).write(^(NSManagedObjectContext *context) {
            User *user = [User createInContext:context];
            user.firstname = @"John";
            user.lastname = @"Doe";
        }).read(^(NSManagedObjectContext *context) {
            NSArray *users = [User allInContext:context];
            XCTAssertEqual(users.count, 1);
            [expectation fulfill];
        });
        
    });
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

@end
