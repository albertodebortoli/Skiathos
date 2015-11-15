//
//  UserPO.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserPO;

@interface UserPOBuilder : NSObject

@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;

- (UserPO *)build;

@end

@interface UserPO : NSObject

@property (nonatomic, copy, readonly) NSString *firstname;
@property (nonatomic, copy, readonly) NSString *lastname;

+ (instancetype)userWithBlock:(void(^)(UserPOBuilder *builder))block;

@end
