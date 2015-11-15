//
//  User+PO.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "User.h"
#import "UserPO.h"

@interface User (PO)

- (UserPO *)userPO;

@end
