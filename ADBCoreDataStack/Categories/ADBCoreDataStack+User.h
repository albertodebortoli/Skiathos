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

- (JEFuture *)allUsers;
- (JEFuture *)currentUser;
- (JEFuture *)saveUser:(UserPO *)user;

@end
