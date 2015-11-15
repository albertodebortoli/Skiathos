//
//  User+PO.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "User+PO.h"

@implementation User (PO)

- (UserPO *)userPO
{
    return [UserPO userWithBlock:^(UserPOBuilder *builder) {
        builder.firstname = self.firstname;
        builder.lastname = self.lastname;
    }];
}

@end
