//
//  ADBCoreDataStack+User.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack+User.h"
#import "User.h"
#import "NSArray+Functional.h"
#import "User+PO.h"

NSString *const kUserEntityName = @"User";

@implementation ADBCoreDataStack (User)

- (JEFuture *)allUsers
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kUserEntityName
                                                         inManagedObjectContext:self.DALService.mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [self.DALService executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError)
        {
            [promise setError:fut.error];
        }
        else
        {
            NSArray *results = [fut result];
            NSArray *pos = [results mapUsingBlock:^id(User *user) {
                return [user userPO];
            }];
            [promise setResult:pos];
        }
    });
    
    return [promise future];
}

- (JEFuture *)currentUser
{
    JEPromise *promise = [[JEPromise alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kUserEntityName
                                                         inManagedObjectContext:self.DALService.mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchLimit:1];
    
    [self.DALService executeFetchRequest:request].continueOnMainQueue(^(JEFuture *fut) {
        
        if (fut.hasError)
        {
            [promise setError:fut.error];
        }
        else
        {
            User *result = [[fut result] firstObject];
            [promise setResult:[result userPO]];
        }
    });
    
    return [promise future];
}

- (JEFuture *)saveUser:(UserPO *)user
{
    return [self.DALService writeBlock:^(NSManagedObjectContext *localContext) {
        User *mo = [NSEntityDescription insertNewObjectForEntityForName:kUserEntityName inManagedObjectContext:localContext];
        mo.firstname = user.firstname;
        mo.lastname = user.lastname;
    }];
}

@end
