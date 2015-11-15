//
//  UserPO.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "UserPO.h"

@interface UserPO ()

- (instancetype)initWithBuilder:(UserPOBuilder *)builder;

@end

@implementation UserPOBuilder

- (UserPO *)build
{
    return [[UserPO alloc] initWithBuilder:self];
}

@end

@implementation UserPO

- (instancetype)initWithBuilder:(UserPOBuilder *)builder
{
    self = [super init];
    if (self) {
        _firstname = builder.firstname;
        _lastname = builder.lastname;
    }
    
    return self;
}

+ (instancetype)userWithBlock:(void(^)(UserPOBuilder *))block
{
    NSParameterAssert(block);
    
    UserPOBuilder *builder = [[UserPOBuilder alloc] init];
    block(builder);
    return [builder build];
}

@end
