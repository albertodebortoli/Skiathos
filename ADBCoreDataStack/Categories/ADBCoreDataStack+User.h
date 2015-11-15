//
//  ADBCoreDataStack+User.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"
#import "UserPO.h"

@interface ADBCoreDataStack (User)

- (NSArray *)allUsers;
- (UserPO *)currentUser;
- (JEFuture *)saveUser:(UserPO *)user;

@end
