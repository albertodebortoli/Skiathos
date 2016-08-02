//
//  NSManagedObject_SkiathosTests.m
// 
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Skiathos.h"
#import "User.h"

#define kUnitTestTimeout (10.0)

@interface NSManagedObject_SkiathosTests : XCTestCase

@property (nonatomic, strong) Skiathos *skiathos;

@end

@implementation NSManagedObject_SkiathosTests

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

- (void)test_CreateObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 0);
    }];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User SK_createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    __block User *user = nil;
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        user = [User SK_createInContext:context];
        user = [user SK_inContext:context];
        [User SK_createInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
    }];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *userInContext = [user SK_inContext:context];
        [userInContext SK_deleteInContext:context];
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteObjectInSameTransactionalBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = nil;
        User *user1 = [User SK_createInContext:context];
        [User SK_createInContext:context];
        users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
        
        [user1 SK_deleteInContext:context];
        users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_DeleteAllObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = nil;
        
        [User SK_createInContext:context];
        [User SK_createInContext:context];
        users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
        
        [User SK_deleteAllInContext:context];
        users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 0);
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_numberOfEntities
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User SK_createInContext:context];
        [User SK_createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSUInteger numberOfEntitities = [User SK_numberOfEntitiesInContext:context];
        XCTAssertEqual(numberOfEntitities, 2);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_numberOfEntitiesWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"firstname", @"John"];
        NSUInteger numberOfEntitities = [User SK_numberOfEntitiesWithPredicate:predicate inContext:context];
        XCTAssertEqual(numberOfEntitities, 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_all
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        [User SK_createInContext:context];
        [User SK_createInContext:context];
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allInContext:context];
        XCTAssertEqual(users.count, 2);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"firstname", @"John"];
        NSArray *users = [User SK_allWithPredicate:predicate inContext:context];
        XCTAssertEqual(users.count, 1);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"John");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWithPredicateSortedBy
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        User *u3 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
        u3.firstname = @"Mark";
        u3.lastname  = @"Smith";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"lastname", @"Doe"];
        NSArray *users = [User SK_allWithPredicate:predicate sortedBy:@"firstname" ascending:YES inContext:context];
        XCTAssertEqual(users.count, 2);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"Jane");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_allWhereAttributeIsEqualToSortedBy
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        User *u3 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
        u3.firstname = @"Mark";
        u3.lastname  = @"Smith";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSArray *users = [User SK_allWhereAttribute:@"lastname" isEqualTo:@"Doe" sortedBy:@"firstname" ascending:NO inContext:context];
        XCTAssertEqual(users.count, 2);
        User *user = [users firstObject];
        XCTAssertEqual(user.firstname, @"John");
        users = [User SK_allWhereAttribute:@"lastname" isEqualTo:@"Doe" sortedBy:@"firstname" ascending:YES inContext:context];
        XCTAssertEqual(users.count, 2);
        user = [users firstObject];
        XCTAssertEqual(user.firstname, @"Jane");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_first
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u2.firstname = @"Jane";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        User *user = [User SK_firstInContext:context];
        XCTAssertNotNil(user);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_firstWithPredicate
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"lastname", @"Doe"];
        User *user = [User SK_firstWithPredicate:predicate sortedBy:@"firstname" ascending:YES inContext:context];
        XCTAssertEqual(user.firstname, @"Jane");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

- (void)test_firstWhereAttribute
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [self.skiathos write:^(NSManagedObjectContext * _Nonnull context) {
        User *u1 = [User SK_createInContext:context];
        User *u2 = [User SK_createInContext:context];
        u1.firstname = @"John";
        u1.lastname  = @"Doe";
        u2.firstname = @"Jane";
        u2.lastname  = @"Doe";
    }];
    
    [self.skiathos read:^(NSManagedObjectContext * _Nonnull context) {
        User *user1 = [User SK_firstWhereAttribute:@"lastname" isEqualTo:@"Doe" inContext:context];
        XCTAssertNotNil(user1);
    
        User *user2 = [User SK_firstWhereAttribute:@"lastname" isEqualTo:@"Smith" inContext:context];
        XCTAssertNil(user2);
    
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kUnitTestTimeout handler:nil];
}

@end
