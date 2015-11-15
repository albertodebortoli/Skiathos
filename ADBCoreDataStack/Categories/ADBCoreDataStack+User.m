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

- (NSArray *)allUsers
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kUserEntityName
                                                         inManagedObjectContext:self.DALService.mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSArray *results = [self.DALService executeFetchRequest:request];
    
    return [results mapUsingBlock:^id(User *user) {
        return [user userPO];
    }];
}

- (UserPO *)currentUser
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kUserEntityName
                                                         inManagedObjectContext:self.DALService.mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [request setFetchLimit:1];
    
    NSArray *results = [self.DALService executeFetchRequest:request];
    
    User *user = [results firstObject];
    
    return [user userPO];
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
